//
//  RMOSPTileSourceManager.h
//  MapView
//
//  Created by Nikita Medvedev on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"

@interface RMOSPTileSourceManager : NSObject

-(id) initWithResource:(NSString*)resource;
-(NSData*) dataForTile:(RMTile)tile;

@end
