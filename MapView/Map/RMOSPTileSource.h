//
//  OSPTileSource.h
//  MapView
//
//  Created by Nikita Medvedev on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileSource.h"
#import "RMMapContents.h"

#import "FMDatabase.h"

//#import "OSPRenderer.h"

#define kOSPDefaultTileSize 256
#define kOSPDefaultMinTileZoom 2
#define kOSPDefaultMaxTileZoom 17
#define kOSPDefaultLatLonBoundingBox ((RMSphericalTrapezium){ .northeast = { .latitude =  90, .longitude =  180 }, \
.southwest = { .latitude = -90, .longitude = -180 } })

@class OSPRenderer, FMDatabase, Guide, Showplace;

@interface RMOSPTileSource : NSObject <RMTileSource>//, OSPObjectsLoader>
{
	RMMapContents *contents;
}

@property (nonatomic, retain) RMMapContents *contents;

-(id) initWithMapFile:(NSString*)mapFile;
-(id) initWithMapFileInFolder:(NSString*)resource andId:(NSInteger)cityId;

+(void) initializeWithFolder:(NSString*)folder andId:(NSInteger)cityId;

+(OSPRenderer*) newRendererForResource:(NSString*)resource;
+(FMDatabase*) newCacheDataBaseForResource:(NSString*)resource;

+(UIImage*) renderImageForTile:(RMTile)tile withRenderer:(OSPRenderer*)renderer andDatabase:(FMDatabase*)cacheDatabase shouldCache:(BOOL*)shouldCache;

+(RMLatLong) tileToLatLon:(RMTile)tile;
+(RMTile) latLonToTile:(RMLatLong)latLon onZoom:(int)zoom;

-(void) writeCacheIntoDisk;

-(RMTileImage *) tileImage: (RMTile) tile;
- (NSString *)constraints;
-(NSString *) tileURL: (RMTile) tile;
-(NSString *) tileFile: (RMTile) tile;
-(NSString *) tilePath;
-(id<RMMercatorToTileProjection>) mercatorToTileProjection;
-(RMProjection*) projection;

-(float) minZoom;
-(float) maxZoom;

-(void) setMinZoom:(NSUInteger) aMinZoom;
-(void) setMaxZoom:(NSUInteger) aMaxZoom;

-(RMSphericalTrapezium) latitudeLongitudeBoundingBox;

-(void) didReceiveMemoryWarning;

-(NSString *)uniqueTilecacheKey;

-(NSString *)shortName;
-(NSString *)longDescription;
-(NSString *)shortAttribution;
-(NSString *)longAttribution;

-(void)removeAllCachedImages;

+(void) renderAndCacheResource:(NSArray*)array;

@end
