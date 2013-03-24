//
//  OSPWay.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import "OSPAPIObject.h"

@interface OSPWay : OSPAPIObject
{
@public
	int **cNodes;
	int *cLength;
	float *labelPosition;
	int nodesCount;
	BOOL isArea;
	NSString *name;
}

@property (nonatomic, readwrite,retain/*strong*/) NSArray *nodes;
@property (nonatomic, readwrite,retain/*strong*/) NSArray *nodeObjects;
//@property (nonatomic, retain/*strong*/) NSString *area;
@property (nonatomic, retain/*strong*/) NSString *name;

- (void)addNodeWithId:(NSInteger)nodeId;

- (OSPCoordinate2D)projectedCentroid;

- (double)length;
- (double)textOffsetForTextWidth:(double)width;
- (OSPCoordinate2D)positionOnWayWithOffset:(double)xOffset heightAboveWay:(double)yOffset backwards:(BOOL)backwards;

@end
