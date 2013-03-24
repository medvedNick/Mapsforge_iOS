//
//  OSPMapCSSStyledObject.m
//  OpenStreetPad
//
//  Created by Thomas Davie on 20/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import "OSPMapCSSStyledObject.h"
#import "OSPMapCSSSize.h"
#import "OSPMapCSSSpecifierList.h"
#import "OSPMapCSSSizeSpecifier.h"

@implementation OSPMapCSSStyledObject

@synthesize object;
@synthesize style;

+ (id)object:(OSPAPIObject *)o withStyle:(NSDictionary *)style
{
    return [[self alloc] initWithObject:o style:style];// autorelease];
}

- (id)initWithObject:(OSPAPIObject *)o style:(NSDictionary *)s
{
    self = [super init];
    
    if (nil != self)
    {
        [self setObject:o];
        [self setStyle:s];
		z = -1;
//		z = (float)[(OSPMapCSSSize*)[(OSPMapCSSSizeSpecifier*)[[(OSPMapCSSSpecifierList*)[s objectForKey:@"z-index"] specifiers] objectAtIndex:0] sizeValue] value];
//		level = [[[o tags] objectForKey:@"layer"] intValue];
    }
    
    return self;
}

@end
