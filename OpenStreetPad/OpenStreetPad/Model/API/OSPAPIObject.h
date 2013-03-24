//
//  OSPApiObject.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPCoordinateRect.h"

typedef enum
{
    OSPMemberTypeNode     = 0x0,
    OSPMemberTypeWay      = 0x1,
    OSPMemberTypeRelation = 0x2,
    OSPMemberTypeNone     = 0x3
} OSPMemberType;

@class OSPMap;

@class OSPAPIObjectReference;

@interface OSPAPIObject : NSObject <OSPBounded>

@property (nonatomic, readwrite, assign) NSInteger identity;
@property (nonatomic, readwrite, assign) NSUInteger version;
@property (nonatomic, readwrite, assign) NSUInteger changesetId;
@property (nonatomic, readwrite, retain/*strong*/) NSString *user;
@property (nonatomic, readwrite, assign) NSUInteger userId;
@property (nonatomic, readwrite, assign) BOOL visible;
@property (nonatomic, readwrite, retain/*strong*/) NSDate *timestamp;

@property (nonatomic, readwrite, retain/*copy*/  ) NSDictionary *tags;

@property (nonatomic, readwrite, retain/*copy*/  ) NSSet *parents;

@property (nonatomic, readwrite, /*weak*/assign) OSPMap *map;

@property (nonatomic, readonly) OSPMemberType memberType;

- (id)initUnsafely;

- (BOOL)isEqualToAPIObject:(OSPAPIObject *)object;

- (NSSet *)childObjects;
- (void)addParent:(OSPAPIObjectReference *)newParent;

- (id)valueForTag:(NSString *)tagName;

@end
