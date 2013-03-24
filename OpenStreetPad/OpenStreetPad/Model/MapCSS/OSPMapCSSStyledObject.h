//
//  OSPMapCSSStyledObject.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 20/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import "OSPAPIObject.h"

@interface OSPMapCSSStyledObject : NSObject
{
@public
	float z;
	int level;
}

@property (nonatomic, readwrite,assign/*weak*/) OSPAPIObject *object;
@property (nonatomic, readwrite, retain/*copy*/) NSDictionary *style;

+ (id)object:(OSPAPIObject *)o withStyle:(NSDictionary *)style;
- (id)initWithObject:(OSPAPIObject *)o style:(NSDictionary *)style;

@end
