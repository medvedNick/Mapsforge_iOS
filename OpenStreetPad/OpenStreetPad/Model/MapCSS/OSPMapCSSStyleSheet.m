//
//  OSPMapCSSStyleSheet.m
//  OpenStreetPad
//
//  Created by Thomas Davie on 05/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import "OSPMapCSSStyleSheet.h"

#import "OSPMapCSSStyledObject.h"

#import <objc/runtime.h>

static char styleRef;
static char oldZoomRef;

@implementation OSPMapCSSStyleSheet
{
	NSMutableArray *cachedStyles;
	NSMutableArray *cachedTags;
	NSMutableDictionary *cachedNames;
	NSMutableDictionary *cache;
	float oldZoom;
}

@synthesize ruleset;

- (id)initWithRules:(OSPMapCSSRuleset *)initRuleset
{
    self = [super init];
    
    if (nil != self)
    {
        [self setRuleset:initRuleset];

		cachedStyles = [[NSMutableArray alloc] init];
		cachedTags = [[NSMutableArray alloc] init];
		cachedNames = [[NSMutableDictionary alloc] init];
		cache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)loadImportsRelativeToURL:(NSURL *)baseURL
{
    [[self ruleset] loadImportsRelativeToURL:baseURL];
}

- (NSArray *)styledObjects:(/*NSSet*/NSMutableArray *)objects atZoom:(float)zoom
{
	if (oldZoom != zoom)
	{
//		[cachedStyles removeAllObjects];
//		for (int i = 0; i < cachedNames.count; i++)
//		{
//			[cachedStyles addObject:[NSNull null]];
//		}
		[cache removeAllObjects];
		oldZoom = zoom;
	}
	
    NSMutableArray *styledObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    for (OSPAPIObject *object in objects)
    {
		NSMutableDictionary *tagsWithoutName = [object.tags mutableCopy];
		[tagsWithoutName removeObjectForKey:@"name"];
		[tagsWithoutName removeObjectForKey:@"addr:housenumber"];
		NSDictionary *layerStyles = [cache objectForKey:tagsWithoutName];
		if (layerStyles == nil)
		{
			layerStyles = [ruleset applyToObject:object atZoom:zoom];
			[cache setObject:layerStyles forKey:tagsWithoutName];
		}

		for (NSString *layerStyle in layerStyles)
		{
			OSPMapCSSStyledObject *o = [[OSPMapCSSStyledObject alloc] initWithObject:object style:[layerStyles objectForKey:layerStyle]];
			[styledObjects addObject:o];
//			[o release];
		}

//		[tagsWithoutName release];
		
//        NSNumber *cachedStyleZoom = objc_getAssociatedObject(object, &oldZoomRef);
//        NSArray *newStyledObjects = nil;
//        if ([cachedStyleZoom floatValue] == zoom)
//        {
//            newStyledObjects = objc_getAssociatedObject(object, &styleRef);
//        }
//        if (nil == newStyledObjects)
//        {
//            NSDictionary *layerStyles = [[self ruleset] applyToObject:object atZoom:zoom];
//            NSMutableArray *sos = [NSMutableArray arrayWithCapacity:[layerStyles count]];
//            for (NSString *layerStyle in layerStyles)
//            {
//                [sos addObject:[OSPMapCSSStyledObject object:object withStyle:[layerStyles objectForKey:layerStyle]]];
//            }
//            newStyledObjects = [sos copy];
//            objc_setAssociatedObject(object, &styleRef, newStyledObjects, OBJC_ASSOCIATION_RETAIN);
//            objc_setAssociatedObject(object, &oldZoomRef, [NSNumber numberWithFloat:zoom], OBJC_ASSOCIATION_RETAIN);
//        }
//        [styledObjects addObjectsFromArray:newStyledObjects];
    }
    return styledObjects;
}

- (NSDictionary *)styleForCanvasAtZoom:(float)zoom
{
    return [[self ruleset] styleForCanvasAtZoom:zoom];
}

@end
