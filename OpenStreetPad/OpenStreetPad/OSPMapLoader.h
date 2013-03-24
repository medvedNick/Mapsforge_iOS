//
//  OSPMapLoader.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 4/28/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MapDatabase.h"
#import "MapDatabaseCallback.h"

#import "OSPMapArea.h"

@interface OSPMapLoader : NSObject <MapDatabaseCallback>

@property (nonatomic, retain) NSMutableArray *mapObjects;
@property (nonatomic) OSPMapArea mapArea;

- (id) initWithFile:(NSString*)path;

- (void) executeQueryForTileX:(int)x Y:(int)y Zoom:(int)zoom;

- (void) renderPointOfInterest:(char)layer latitude:(int)latitude longitude:(int)longitude tags:(NSMutableArray *)tags;
- (void) renderWaterBackground;
- (void) renderWay:(char)layer labelPosition:(float *)labelPosition tags:(NSMutableArray *)tags wayNodes:(float**)wayNodes;

- (void) addNode:(int)nodeId latitude:(int)latitude longitude:(int)longitude tags:(NSMutableDictionary *)tags;
- (void) addWay:(int)wayId nodes:(int **)nodes length:(int*)length labelPosition:(float *)labelPosition tags:(NSMutableDictionary *)tags layer:(int)layer;

@end
