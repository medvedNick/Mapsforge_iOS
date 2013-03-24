//
//  OSPPBFFile.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/12/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPDataSource.h"
#import "OSPDataStore.h"

#import "Osmformat.pb.h"
#import "Fileformat.pb.h"

@interface OSPPBFFile : OSPDataSource <OSPDataStore, OSPPersistingStore>

+(id) pbfFileWithFile:(NSString *)path;
-(id) initWithFile:(NSString*)path;

-(void) loadObjectsFromFile:(NSString *)resource;
-(void) loadObjectsFromData:(NSData*)data;

@property (readwrite, strong) NSString *path;
@property (readwrite, strong) id<OSPDataProvider, OSPDataStore> cache;

@end