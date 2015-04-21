//
//  OSPTileSource.h
//  MapView
//
//  Created by Nikita Medvedev on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMAbstractContagtTileSource.h"
#import "RMLatLong.h"
//#import "RMMapContents.h"

#import "../../fmdb/FMDatabase.h"

//#import "OSPRenderer.h"

#define kOSPDefaultTileSize 256
#define kOSPDefaultMinTileZoom 12
#define kOSPDefaultMaxTileZoom 21

@class OSPRenderer, FMDatabase, Guide, Showplace;

@interface RMOSPTileSource : RMAbstractContagtTileSource//, OSPObjectsLoader>
{
	//RMMapContents *contents;
    long building_id;
    int floorLevel;
}

//@property (nonatomic, retain) RMMapContents *contents;

-(id) initWithMapFile:(NSString*)mapFile andBuilding:(long)building_id andFloorlevel:(int) floorlevel;

+(OSPRenderer*) newRendererForResource:(NSString*)resource;
+(FMDatabase*) newCacheDataBaseForResource:(NSString*)resource;

+(UIImage*) renderImageForTile:(RMTile)tile withRenderer:(OSPRenderer *)renderer andDatabase:(FMDatabase *)cacheDatabase building:(long)bid floor:(int)floor shouldCache:(BOOL*)shouldCache;

+(RMLatLong) tileToLatLon:(RMTile)tile;
+(RMTile) latLonToTile:(RMLatLong)latLon onZoom:(int)zoom;

-(float) minZoom;
-(float) maxZoom;

-(void) setMinZoom:(NSUInteger) aMinZoom;
-(void) setMaxZoom:(NSUInteger) aMaxZoom;

-(void) didReceiveMemoryWarning;

-(NSString *)uniqueTilecacheKey;

-(NSString *)shortName;
-(NSString *)longDescription;
-(NSString *)shortAttribution;
-(NSString *)longAttribution;

-(void)removeAllCachedImages;

@end
