//
//  OSPMember.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import "OSPAPIObject.h"

#import "OSPMap.h"

@class OSPRelation;

@interface OSPMember : NSObject

+ (id)memberWithType:(OSPMemberType)memberType referencedObjectId:(NSInteger)referenceId role:(NSString *)role;
- (id)initWithType:(OSPMemberType)memberType referencedObjectId:(NSInteger)referenceId role:(NSString *)role;

@property (nonatomic, readwrite, assign) OSPMemberType referencedObjectType;
@property (nonatomic, readwrite, assign) NSInteger referencedObjectId;
@property (nonatomic, readwrite, retain/*copy*/  ) NSString *role;
@property (nonatomic, readwrite, /*weak*/assign  ) OSPRelation *relation;

@property (nonatomic, readonly) OSPAPIObject *referencedObject;

@property (nonatomic, readonly) OSPCoordinateRect bounds;

@end
