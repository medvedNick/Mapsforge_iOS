//
//  OSPNode.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import "OSPAPIObject.h"

#import <CoreLocation/CoreLocation.h>

@interface OSPNode : OSPAPIObject

@property (/*nonatomic,*/ readonly, assign) CLLocationCoordinate2D location;
@property (/*nonatomic,*/ readonly , assign) OSPCoordinate2D projectedLocation;

@end
