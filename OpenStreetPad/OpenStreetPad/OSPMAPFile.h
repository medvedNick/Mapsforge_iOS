//
//  OSPMAPFile.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/27/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapDatabase.h"
#import "MapDatabaseCallback.h"

#import "OSPDataSource.h"
#import "OSPDataStore.h"

@interface OSPMAPFile : OSPDataSource <OSPDataStore, OSPPersistingStore, MapDatabaseCallback>

+(id) mapFileWithFile:(NSString *)path;
-(id) initWithFile:(NSString*)path;

- (void) renderPointOfInterest:(char)layer latitude:(int)latitude longitude:(int)longitude tags:(NSMutableArray *)tags;
- (void) renderWaterBackground;
- (void) renderWay:(char)layer labelPosition:(float *)labelPosition tags:(NSMutableArray *)tags wayNodes:(float**)wayNodes;

- (void) addNode:(int)nodeId latitude:(double)latitude longitude:(double)longitude tags:(NSMutableDictionary *)tags;
- (void) addWay:(int)wayId nodes:(NSMutableArray *)nodeIds tags:(NSMutableDictionary *)tags;

-(void) loadObjectsForTileX:(int)x Y:(int)y zoom:(int)zoom;

@property (readwrite, strong) NSString *path;
@property (readwrite, strong) id<OSPDataProvider, OSPDataStore> cache;

@end
