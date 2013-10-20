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

#import "OSPRenderer.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#define kCacheThresh 300

BOOL runInBackground;

@implementation RMOSPTileSource
{
	RMFractalTileProjection *tileProjection;
	OSPRenderer *renderer;
	FMDatabase *cacheDatabase;
	NSMutableArray *imagesCache;
	NSLock *cacheLock;
}

@synthesize contents;

-(id) initWithMapFile:(NSString*)mapFile
{
	self = [super init];
	if (self)
	{
		renderer = [RMOSPTileSource newRendererForResource:mapFile];
		cacheDatabase = nil;
		tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[self projection] 
															  tileSideLength:kOSPDefaultTileSize 
																	 maxZoom:kOSPDefaultMaxTileZoom 
																	 minZoom:kOSPDefaultMinTileZoom];
		imagesCache = [[NSMutableArray alloc] initWithCapacity:10];
		cacheLock = [[NSLock alloc] init];
	}
	return self;	
}

-(id) initWithMapFileInFolder:(NSString*)folder andId:(NSInteger)cityId
{
	self = [super init];
	if (self)
	{
		NSString *resource = [NSString stringWithFormat:@"%@/%d.map", folder, cityId];
		NSString *dbresource = [NSString stringWithFormat:@"%@/%dcache.sqlite3", folder, cityId];
		renderer = [RMOSPTileSource newRendererForResource:resource];
		cacheDatabase = [RMOSPTileSource newCacheDataBaseForResource:dbresource];
		tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[self projection] 
															  tileSideLength:kOSPDefaultTileSize 
																	 maxZoom:kOSPDefaultMaxTileZoom 
																	 minZoom:kOSPDefaultMinTileZoom];
		imagesCache = [[NSMutableArray alloc] initWithCapacity:10];
		cacheLock = [[NSLock alloc] init];
	}
	return self;
}

+(OSPRenderer*) newRendererForResource:(NSString*)resource
{
	return [[OSPRenderer alloc] initWithFile:resource];		
}

+(FMDatabase*) newCacheDataBaseForResource:(NSString*)resource
{
	BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:resource];

	FMDatabase *_cacheDatabase = [[FMDatabase alloc] initWithPath:resource];

	if (![_cacheDatabase open])
	{
		NSLog(@"cached database could not be opened!");
		return nil;
	}

	if (!databaseExists)
	{
		[_cacheDatabase executeUpdate:@"create table OSPCachedTiles (cityId integer, x double, y double, zoom double, tileData blob)"];		
	}

	if ([_cacheDatabase hadError])
	{
		NSLog(@"%@", [_cacheDatabase lastErrorMessage]);
		return nil;
	}
	
	return _cacheDatabase;
}

+(UIImage*) renderImageForTile:(RMTile)tile withRenderer:(OSPRenderer *)renderer andDatabase:(FMDatabase *)cacheDatabase shouldCache:(BOOL*)shouldCache
{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UIImage *image;
	
	NSData *data = [cacheDatabase dataForQuery:@"select tileData from OSPCachedTiles where zoom = ? and x = ? and y = ?", 
					[NSNumber numberWithFloat:tile.zoom], 
					[NSNumber numberWithFloat:tile.x], 
					[NSNumber numberWithFloat:tile.y]];
	
	BOOL _shouldCache = YES;
	
	if (data != nil)
	{
		NSLog(@"got from cache!");
		UIImage *cachedImage = [UIImage imageWithData:data];
		return cachedImage;
	}
	
	RMLatLong latLon = [RMOSPTileSource tileToLatLon:tile];
	
	OSPMapArea mapArea = OSPMapAreaMake(OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(latLon.latitude, latLon.longitude)), tile.zoom);
	
	[renderer setMapArea:mapArea];
	
	image = [renderer imageForTileX:tile.x Y:tile.y zoom:tile.zoom];

	_shouldCache = _shouldCache && (renderer.objectsNumber > kCacheThresh) && cacheDatabase != nil;
	
	if (shouldCache != nil)
	{
		*shouldCache = _shouldCache;
	}
	else
	{
		NSLog(@"instantly cached!");
		[cacheDatabase beginTransaction];
		[cacheDatabase executeUpdate:@"insert into OSPCachedTiles (x, y, zoom, tileData) values (?, ?, ?, ?)",
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

-(RMTileImage *) tileImage: (RMTile) tile
{
	runInBackground = NO;
	RMTileImage *tileImage = [[[RMTileImage alloc] initWithTile:tile] autorelease];
	
	UIImage *image;
	BOOL shouldCache;
//	NSLog(@"%d, %d, %d", tile.x, tile.y, tile.zoom);
	@try {
		image = [RMOSPTileSource renderImageForTile:tile withRenderer:renderer andDatabase:cacheDatabase shouldCache:&shouldCache];
		
		if (shouldCache)
		{
			NSArray *tileCache = [NSArray arrayWithObjects:
								  [NSNumber numberWithInt:tile.x],
								  [NSNumber numberWithInt:tile.y],
								  [NSNumber numberWithInt:tile.zoom],
								  image, nil];
			[cacheLock lock];			  
			[imagesCache addObject:tileCache];
			[cacheLock unlock];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Exception while creating image: %@", exception.reason);
	}
	
	[tileImage updateImageUsingImage:image];
	return tileImage;
}

-(void) writeCacheIntoDisk
{
//	NSLog(@"wrote cache into disk");
	[cacheLock lock];
	for (NSMutableArray *array in imagesCache)
	{
		int x = [[array objectAtIndex:0] intValue];
		int y = [[array objectAtIndex:1] intValue];
		int zoom = [[array objectAtIndex:2] intValue];
		UIImage *image = [array objectAtIndex:3];
		[cacheDatabase beginTransaction];
		[cacheDatabase executeUpdate:@"insert into OSPCachedTiles (x, y, zoom, tileData) values (?, ?, ?, ?)",
		 [NSNumber numberWithInt:x],
		 [NSNumber numberWithInt:y],
		 [NSNumber numberWithInt:zoom],
		 (NSData*)UIImagePNGRepresentation(image)];
		[cacheDatabase commit];
		if ([cacheDatabase hadError])
		{
			NSLog(@"Error while caching: %@", [cacheDatabase lastErrorMessage]);
		}
	}
	[imagesCache removeAllObjects];
	[cacheLock unlock];
}

+(void) renderAndCacheResource:(NSArray*)array
{
	return;
	NSString *folder = [array objectAtIndex:0];
	NSNumber *guideId = [array objectAtIndex:1];
	CLLocation *loc = [array objectAtIndex:2];
	[RMOSPTileSource initializeWithFolder:folder andId:[guideId intValue]];

	NSString *resource = [NSString stringWithFormat:@"%@/%d.map", folder, guideId];
	NSString *dbresource = [NSString stringWithFormat:@"%@/%dcache.sqlite3", folder, guideId];
	OSPRenderer *renderer = [RMOSPTileSource newRendererForResource:resource];
	FMDatabase *cacheDatabase = [RMOSPTileSource newCacheDataBaseForResource:dbresource];
	
	runInBackground = YES;
	
//	CLLocation *loc = [[CLLocation alloc] initWithLatitude:55.753507 longitude:37.621253];
//	CLLocation *loc = [[CLLocation alloc] initWithLatitude:51.497975 longitude:-0.051901];

	RMLatLong latLon = [loc coordinate];

	int xCenter, yCenter;
	int delta = 3;

	for (int zoom = 11; zoom < 15; zoom++)
	{
		RMTile tile = [RMOSPTileSource latLonToTile:latLon onZoom:zoom];
		xCenter = tile.x;
		yCenter = tile.y;		
		
		for (int x = xCenter-delta; x < xCenter+delta; x++)
		{
			for (int y = yCenter-delta; y < yCenter+delta; y++)
			{
				if (runInBackground == NO) break;
				NSData *data = [cacheDatabase dataForQuery:@"select tileData from OSPCachedTiles where zoom = ? and x =	 ? and y = ?", 
								[NSNumber numberWithFloat:zoom], 
								[NSNumber numberWithFloat:x], 
								[NSNumber numberWithFloat:y]];
				if (data != nil) continue;

				RMTile currentTile = { .x = x, .y = y, .zoom = zoom };
				RMLatLong currentLatLon = [RMOSPTileSource tileToLatLon:currentTile];
				
				OSPMapArea mapArea = OSPMapAreaMake(OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(currentLatLon.latitude, currentLatLon.longitude)), currentTile.zoom);

				renderer.mapArea = mapArea;
				[RMOSPTileSource renderImageForTile:currentTile withRenderer:renderer andDatabase:cacheDatabase shouldCache:nil];
			}
		}
	}
	
//	[cacheDatabase close];
}

+(RMLatLong) tileToLatLon:(RMTile)tile
{
	RMProjectedRect planetRect = [[RMProjection googleProjection] planetBounds];
	
	double scale = 1 << tile.zoom;
	double x = tile.x, y = tile.y;
	double _x = (2*x+1)/(2*scale) * planetRect.size.width + planetRect.origin.easting;
	double _y = planetRect.origin.northing - ((2*y+1)/(2*scale) - 1)*planetRect.size.height;
	
	RMProjectedPoint newPoint = RMMakeProjectedPoint(_x, _y);
	RMLatLong currentLatLon = [[RMProjection googleProjection] pointToLatLong:newPoint];
	
	return currentLatLon;
}

+(RMTile) latLonToTile:(RMLatLong)latLon onZoom:(int)zoom
{
	RMProjectedRect planetRect = [[RMProjection googleProjection] planetBounds];
	RMProjectedPoint center = [[RMProjection googleProjection] latLongToPoint:latLon];
	
	double x, y;
	
	x = ((center.easting-planetRect.origin.easting)*2*(1 << zoom)/planetRect.size.width-1)/2;
	y = ((planetRect.origin.northing-center.northing)/planetRect.size.height+1)*2*(1 << zoom)/2;
	
	RMTile tile = { .x = x, .y = y, .zoom = zoom };
	
	return tile;
}


- (NSString *)constraints
{
    return nil;
}

-(NSString *) tileURL: (RMTile) tile
{
	return nil;
}

-(NSString *) tileFile: (RMTile) tile
{
	return nil;
}

-(NSString *) tilePath
{
	return nil;
}

-(id<RMMercatorToTileProjection>) mercatorToTileProjection
{
	return [[tileProjection retain] autorelease];
}

-(RMProjection*) projection
{
	return [RMProjection googleProjection];
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

-(RMSphericalTrapezium) latitudeLongitudeBoundingBox
{
	return kOSPDefaultLatLonBoundingBox;
}

- (int)tileSideLength
{
	return tileProjection.tileSideLength;
}

-(void) didReceiveMemoryWarning
{
	
}

-(NSString *)uniqueTilecacheKey
{
	return nil;//@"OSPTileSource";
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
	
}

-(void) dealloc
{
	[cacheDatabase close];
	[cacheDatabase release];
	[tileProjection release];
	[imagesCache release];
	[cacheLock release];
	[renderer release];
	[super dealloc];
}

@end
