//
//  OSPTileSource.m
//  MapView
//
//  Created by Nikita Medvedev on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RMOSPTileSource.h"
#import "RMTile.h"
#import "RMTileImage.h"
#import "RMProjection.h"
#import "RMFractalTileProjection.h"
#import "RMFoundation.h"

#import "LRUCache.h"

#import "OSPRenderer.h"


#import "../../fmdb/FMDatabase.h"
#import "../../fmdb/FMDatabaseAdditions.h"

#define kCacheThresh 6000
#define kCacheInternalThresh 400

BOOL runInBackground;

@implementation RMOSPTileSource
{
    RMFractalTileProjection *tileProjection;
    OSPRenderer *renderer;
    FMDatabase *cacheDatabase;
    LruCache *imagesCache;
    NSLock *cacheLock;
}

//@synthesize contents;


+ (NSString *) getDBPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"tilecache.sqlite3"];
}

-(id) initWithMapFile:(NSString*)mapFile andBuilding:(long)bid andFloorlevel:(int) flvl
{
    self = [super init];
    if (self)
    {
        building_id = bid;
        floorLevel = flvl;
        
        renderer = [RMOSPTileSource newRendererForResource:mapFile];
        NSString *dbresource = [RMOSPTileSource getDBPath];
        cacheDatabase = [RMOSPTileSource newCacheDataBaseForResource:dbresource];
        imagesCache = [[LruCache alloc] initWithMaxSize:kCacheInternalThresh];// Check if this Capacity is okay
        cacheLock = [[NSLock alloc] init];
    }
    return self;
}


+(OSPRenderer*) newRendererForResource:(NSString*)resource
{
    return [[OSPRenderer alloc] initWithFile:resource];
}

+ (FMDatabase*) newCacheDataBaseForResource:(NSString*)resource
{
    
    resource = [RMOSPTileSource getDBPath];
    BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:resource];
    
    FMDatabase *_cacheDatabase = [[FMDatabase alloc] initWithPath:resource];
    
    if (![_cacheDatabase open])
    {
        NSLog(@"cached database could not be opened!");
        return nil;
    }
    
    if (!databaseExists)
    {
        [_cacheDatabase executeUpdate:@"CREATE TABLE OSPCachedTiles (building_id integer, floor integer, x double, y double, zoom double, tileData blob)"];
        [_cacheDatabase executeUpdate:@"CREATE INDEX osp_tile_index ON OSPCachedTiles (building_id, floor, x, y, zoom)"];
    }
    
    if ([_cacheDatabase hadError])
    {
        NSLog(@"%@", [_cacheDatabase lastErrorMessage]);
        return nil;
    }
    
    return _cacheDatabase;
}

+(UIImage*) renderImageForTile:(RMTile)tile withRenderer:(OSPRenderer *)renderer andDatabase:(FMDatabase *)cacheDatabase building:(long)building_id floor:(int)currentFloor shouldCache:(BOOL*)shouldCache
{
    //	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIImage *image;
    
    //[imagesCache ]
    
    NSData *data = [cacheDatabase dataForQuery:@"SELECT tileData FROM OSPCachedTiles WHERE building_id = ? AND floor = ? AND zoom = ? AND x = ? and y = ?",
                    [NSNumber numberWithLong:building_id],
                    [NSNumber numberWithInt:currentFloor],
                    [NSNumber numberWithFloat:tile.zoom],
                    [NSNumber numberWithFloat:tile.x],
                    [NSNumber numberWithFloat:tile.y]];
    
    if (data != nil)
    {
        return [UIImage imageWithData:data];
    }
    
    RMLatLong latLon = [RMOSPTileSource tileToLatLon:tile];
    OSPMapArea mapArea = OSPMapAreaMake(OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(latLon.latitude, latLon.longitude), tile.zoom, tile.x, tile.y), tile.zoom);
    
    BOOL _shouldCache = NO;
    
    [renderer setMapArea:mapArea];
    
    image = [renderer imageForTileX:tile.x Y:tile.y zoom:tile.zoom];
    
    _shouldCache = _shouldCache && (renderer.objectsNumber > kCacheThresh) && cacheDatabase != nil;
    
    if (_shouldCache == YES)
    {
        [cacheDatabase beginTransaction];
        [cacheDatabase executeUpdate:@"insert into OSPCachedTiles (building_id, floor, x, y, zoom, tileData) values (?, ?, ?, ?, ?, ?)",
         [NSNumber numberWithLong:building_id],
         [NSNumber numberWithInt:currentFloor],
         [NSNumber numberWithInt:tile.x],
         [NSNumber numberWithInt:tile.y],
         [NSNumber numberWithInt:tile.zoom],
         (NSData*)UIImagePNGRepresentation(image)];
        [cacheDatabase commit];
        if ([cacheDatabase hadError])
        {
            NSLog(@"%@", [cacheDatabase lastErrorMessage]);
        }
    }
    
    //	[pool release];
    
    return image;
}

- (UIImage *)imageForTile:(RMTile)tile inCache:(RMTileCache *)tileCache
{
    
    runInBackground = NO;
    //UIImage *tileImage = [RMTileImage missingTile];//[[RMTileImage alloc] initWithTile:tile];
    UIImage *image  = [RMTileImage missingTile];
    BOOL shouldCache = YES;
    @try {
        
        NSString * key = [NSString stringWithFormat:@"%d%d%d%ld%d", tile.x, tile.y, tile.zoom, building_id, floorLevel];
        image = [imagesCache get:key];
        
        if (image == nil) {
            image = [RMOSPTileSource renderImageForTile:tile withRenderer:renderer andDatabase:cacheDatabase building:building_id floor:floorLevel shouldCache:&shouldCache];
            
            if (shouldCache)
            {
                [cacheLock lock];
                [imagesCache put:key value:image];
                [cacheLock unlock];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while creating image: %@", exception.reason);
    }
    
    //[tileImage updateImageUsingImage:image];
    return image;
}

+(RMLatLong) tileToLatLon:(RMTile)tile
{
    RMProjectedRect planetRect = [[RMProjection googleProjection] planetBounds];
    
    double scale = 1 << tile.zoom;
    double x = tile.x, y = tile.y;
    double _x = (2*x+1)/(2*scale) * planetRect.size.width + planetRect.origin.x;
    double _y = planetRect.origin.y - ((2*y+1)/(2*scale) - 1)*planetRect.size.height;
    
    RMProjectedPoint newPoint = RMProjectedPointMake(_x, _y);
    RMLatLong currentLatLon = [[RMProjection googleProjection] projectedPointToCoordinate:newPoint];
    
    return currentLatLon;
}

+(RMTile) latLonToTile:(RMLatLong)latLon onZoom:(int)zoom
{
    RMProjectedRect planetRect = [[RMProjection googleProjection] planetBounds];
    RMProjectedPoint center = [[RMProjection googleProjection] coordinateToProjectedPoint:latLon];
    
    double x, y;
    
    x = ((center.x-planetRect.origin.x)*2*(1 << zoom)/planetRect.size.width-1)/2;
    y = ((planetRect.origin.y-center.y)/planetRect.size.height+1)*2*(1 << zoom)/2;
    
    RMTile tile = { .x = x, .y = y, .zoom = zoom };
    
    return tile;
}


-(float) minZoom
{
    return kOSPDefaultMinTileZoom;
}

-(float) maxZoom
{
    return kOSPDefaultMaxTileZoom;
}


-(void) setMinZoom:(NSUInteger) aMinZoom
{
    
}

-(void) setMaxZoom:(NSUInteger) aMaxZoom
{
    
}


-(void) didReceiveMemoryWarning
{
    
}

-(NSString *)uniqueTilecacheKey
{
    return @"OSPTileCache";//@"OSPTileSource";
}

-(NSString *)shortName
{
    return nil;
}
-(NSString *)longDescription
{
    return nil;
}
-(NSString *)shortAttribution
{
    return nil;
}
-(NSString *)longAttribution
{
    return nil;
}

-(void)removeAllCachedImages
{
    [cacheLock lock];
    [imagesCache evictAll];
    [cacheLock unlock];
}

@end
