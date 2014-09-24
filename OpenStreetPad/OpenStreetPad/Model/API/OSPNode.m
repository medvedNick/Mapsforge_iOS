//
//  OSPNode.m
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import "OSPNode.h"

@interface OSPNode ()

@property (/*nonatomic,*/readwrite,assign) OSPCoordinate2D projectedLocation;

@end

@implementation OSPNode

@synthesize location;
@synthesize projectedLocation;

- (CLLocationCoordinate2D)location
{
    @synchronized(self)
    {
        return location;
    }
}

- (void)setLocation:(CLLocationCoordinate2D)newLocation
{
    @synchronized(self)
    {
        location = newLocation;
		[self setProjectedLocation:OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(location.latitude/1000000, location.longitude/1000000))];
    }
}

- (OSPCoordinateRect)bounds
{
    return OSPCoordinateRectMake(projectedLocation.x, projectedLocation.y, 0.0, 0.0);
}

- (OSPMemberType)memberType
{
    return OSPMemberTypeNode;
}

@end
