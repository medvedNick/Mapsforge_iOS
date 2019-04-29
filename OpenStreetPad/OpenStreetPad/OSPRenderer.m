//
//  OSPRenderer.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/29/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPRenderer.h"

#import "OSPCoordinateRect.h"   //by me

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#import "OSPAPIObject.h"
#import "OSPWay.h"
#import "OSPNode.h"

#import "OSPMapArea.h"

#import "OSPMapCSSParser.h"
#import "OSPMapCSSRule.h"

#import "OSPMapCSSSpecifierList.h"
#import "OSPMapCSSSpecifier.h"
#import "OSPMapCSSSizeSpecifier.h"
#import "OSPMapCSSColourSpecifier.h"
#import "OSPMapCSSNamedSpecifier.h"
#import "OSPMapCSSSize.h"
#import "OSPMapCSSURLSpecifier.h"

#import "OSPMapCSSStyledObject.h"

#import "NSString+OpenStreetPad.h"
#import "UIColor+CSS.h"

#import "OSPMapLoader.h"

void patternCallback(void *info, CGContextRef ctx);

@interface OSPRenderer()
{
	OSPMapArea mapArea;
	NSMutableSet *names;
	OSPMapLoader *mapLoader;
	
	CGFloat _scale;
	CGFloat _zoom;
	CGFloat _factor;
    long _x;
    long _y;
}
- (void)setupContext:(CGContextRef)ctx inRect:(CGRect)b atZoom:(float)zoom;

- (NSDictionary *)sortedObjects:(NSArray *)objects;

- (UIColor *)colourWithColourSpecifierList:(OSPMapCSSSpecifierList *)colour opacitySpecifierList:(OSPMapCSSSpecifierList *)opacity;
- (UIImage *)imageWithSpecifierList:(OSPMapCSSSpecifierList *)spec;

- (CGPathRef)newPathForWay:(OSPWay *)way;
- (CTFontRef)createFontWithStyle:(NSDictionary *)style scaledVariant:(CTFontRef *)scaledFont atScale:(CGFloat)scale;
- (NSString *)applyTextTransform:(NSDictionary *)style toString:(NSString *)str;

- (void)renderLayers:(NSDictionary *)layers inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;

- (void)renderWayFills:(NSArray *)ways inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderWayCasings:(NSArray *)ways inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderLayerObjects:(NSArray *)layer inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderLayerLabels:(NSArray *)layer inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;

- (void)renderWayFill:(OSPMapCSSStyledObject *)way inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderWay:(OSPMapCSSStyledObject *)way inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderCasing:(OSPMapCSSStyledObject *)way inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderNode:(OSPMapCSSStyledObject *)node inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderObjectAtCentroid:(OSPMapCSSStyledObject *)object inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderObject:(OSPMapCSSStyledObject *)obj atPoint:(OSPCoordinate2D)loc inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;

- (void)renderWayLabel:(OSPMapCSSStyledObject *)styledWay inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;
- (void)renderNodeLabel:(OSPMapCSSStyledObject *)styledWay inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale;

- (void)drawText:(NSString *)text atPoint:(CGPoint)textPosition inContext:(CGContextRef)ctx withStyle:(NSDictionary *)style scaleMultiplier:(CGFloat)scale;
- (void)drawText:(NSString *)text onWay:(OSPWay *)textWay inContext:(CGContextRef)ctx withStyle:(NSDictionary *)style scaleMultiplier:(CGFloat)scale;

@end;

CGLineCap CGLineCapFromNSString(NSString *s);
CGLineJoin CGLineJoinFromNSString(NSString *s);

CGLineCap CGLineCapFromNSString(NSString *s)
{
    if ([s isEqualToString:@"round"])
    {
        return kCGLineCapRound;
    }
    else if ([s isEqualToString:@"square"])
    {
        return kCGLineCapSquare;
    }
    else
    {
        return kCGLineCapButt;
    }
}

CGLineJoin CGLineJoinFromNSString(NSString *s)
{
    if ([s isEqualToString:@"bevel"])
    {
        return kCGLineJoinBevel;
    }
    else if ([s isEqualToString:@"miter"])
    {
        return kCGLineJoinMiter;
    }
    else
    {
        return kCGLineJoinRound;
    }
}

@implementation OSPRenderer

@synthesize stylesheet;
@synthesize mapArea;
@synthesize objectsNumber;
@synthesize resource;
	
- (id) initWithFile:(NSString*)path
{
	self = [super init];
	if (self)
	{
		resource = path;
		names = [[NSMutableSet alloc] init];
		mapLoader = [[OSPMapLoader alloc] initWithFile:path];
		NSError *err;
		NSURL *url = [[NSBundle mainBundle] URLForResource:@"osm" withExtension:@"mcs"];
		NSString *style = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
		if (nil != style)
		{
			@try {
				OSPMapCSSParser *p = [[OSPMapCSSParser alloc] init];
				[self setStylesheet:[p parse:style]];
				[[self stylesheet] loadImportsRelativeToURL:[url URLByDeletingLastPathComponent]];
			}
			@catch (NSException *exception) {
				NSLog(@"Exception while parsing: %@", exception.reason);
			}
		}
		objectsNumber = 0;
	}
	return self;
}

- (UIImage*) imageForTileX:(int)x Y:(int)y zoom:(int)zoom
{
	@synchronized(self)
	{
		_zoom = zoom;
        _x = x;
        _y = y;
		[names removeAllObjects];
		mapLoader.mapArea = mapArea;
		[mapLoader executeQueryForTileX:x Y:y Zoom:zoom];

		objectsNumber = mapLoader.mapObjects.count;

		UIImage *image = [self renderImageAtZoom:zoom];
		return image;
	}
}

-(MapDatabase*)getMapDatabase {
    return [mapLoader getMapDatabase];
}

- (UIImage *) renderImageAtZoom:(int)zoom
{
	int imageWidth = 384; // 384
	int layerWidth = 256;
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageWidth), 1, 1);
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone); //TEST!
	CGRect b = CGRectMake(0, 0, layerWidth, layerWidth);
	[self setupContext:context inRect:b atZoom:zoom];
	
	NSArray *styledObjects = [[self stylesheet] styledObjects:mapLoader.mapObjects atZoom:zoom];
	//NSLog(@"loaded: %d, styled: %d", mapLoader.mapObjects.count, styledObjects.count);
	
	switch (zoom) {
		case 22:
			_factor = 0.4;
			break;
		case 21:
			_factor = 0.5;
			break;
		case 20:
			_factor = 0.6;
			break;
		case 19:
			_factor = 0.7;
			break;
		case 18:
			_factor = 0.8;
			break;
		case 17:
			_factor = 1;
			break;
		case 16:
			_factor = 1;
			break;
		case 15:
			_factor = 1;
			break;
		case 14:
			_factor = 1.5;
			break;
		case 13:
			_factor = 4;
		case 12:
			_factor = 8;
		default:
			_factor = 10;
			break;
	}

	float scale = 1/_scale;

	@try {
		NSDictionary *sortedObjects = [self sortedObjects:styledObjects];
		[self renderLayers:sortedObjects inContext:UIGraphicsGetCurrentContext() withScaleMultiplier:scale];
	}
	@catch (NSException *exception) {
		NSLog(@"Exception while drawing: %@, %@", exception.name, exception.reason);
	}
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

-(void) setupContext:(CGContextRef)ctx inRect:(CGRect)b atZoom:(float)zoom
{
    OSPCoordinateRect r = OSPRectForMapAreaInRect([self mapArea], b);
    CGRect clipBounds = CGContextGetClipBoundingBox(ctx);

    _scale = 1.5*b.size.width / r.size.x;
    CGFloat oneOverScale = 1.0f / _scale;

    NSDictionary *canvasStyle = [stylesheet styleForCanvasAtZoom:zoom];
    UIColor *c = [self colourWithColourSpecifierList:[canvasStyle objectForKey:@"fill-color"] opacitySpecifierList:[canvasStyle objectForKey:@"fill-opacity"]];
    UIImage *fillImage = [self imageWithSpecifierList:[canvasStyle objectForKey:@"fill-image"]];
    if (nil != fillImage)
    {
        CGSize s = [fillImage size];
        CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
        CGContextSetFillColorSpace(ctx, patternSpace);
        CGColorSpaceRelease(patternSpace);
        static const CGPatternCallbacks callbacks = { 0, &patternCallback, NULL };
        CGPatternRef pat = CGPatternCreate((__bridge void *)[NSDictionary dictionaryWithObjectsAndKeys:fillImage, @"I", [NSValue valueWithCGSize:s], @"s", nil], CGRectMake(0.0f, 0.0f, s.width, s.height), CGAffineTransformMakeScale(1.0, -1.0), s.width, s.height, kCGPatternTilingNoDistortion, true, &callbacks);
        CGFloat alpha = 1;
        CGContextSetFillPattern(ctx, pat, &alpha);
        CGPatternRelease(pat);
    }
    if (nil != c)
    {
        CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
        CGContextSetFillColorSpace(ctx, rgbSpace);
        CGColorSpaceRelease(rgbSpace);
        CGContextSetFillColorWithColor(ctx, [c CGColor]);
    }
    else
    {
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0.95f green:0.95f blue:0.85f alpha:1.0f] CGColor]);
    }
    CGContextFillRect(ctx, clipBounds);
    
    CGContextScaleCTM(ctx, _scale, _scale);
    CGContextSetLineWidth(ctx, 2.0 * oneOverScale);
    CGContextTranslateCTM(ctx, -r.origin.x, -r.origin.y);
    CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0f, -1.0f));
}


- (UIColor *)colourWithColourSpecifierList:(OSPMapCSSSpecifierList *)colour opacitySpecifierList:(OSPMapCSSSpecifierList *)opacity
{
    UIColor *c = [[[colour specifiers] objectAtIndex:0] colourValue];
    OSPMapCSSSize *op = [[[opacity specifiers] objectAtIndex:0] sizeValue];
    
    if (nil != c && nil != opacity)
    {
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [c getRed:&red green:&green blue:&blue alpha:&alpha];
        alpha = [op value];
        c = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    
    return c;
}

- (NSDictionary *)sortedObjects:(NSArray *)objects
{
    NSMutableDictionary *layers = [NSMutableDictionary dictionaryWithCapacity:5];
    for (OSPMapCSSStyledObject *object in objects)
    {
        NSNumber *layerNumber = [NSNumber numberWithInt:[[[[object object] tags] objectForKey:@"layer"] intValue]];
        NSMutableArray *layer = [layers objectForKey:layerNumber];
        if (nil == layer)
        {
            layer = [NSMutableArray array];
            [layers setObject:layer forKey:layerNumber];
        }
        [layer addObject:object];
    }
	NSMutableDictionary *layersCopy = [layers copy];
    for (NSNumber *layerNumber in layersCopy)
    {
        NSArray *layerObjects = [layers objectForKey:layerNumber];
        [layers setObject:[layerObjects sortedArrayUsingComparator:^ NSComparisonResult (OSPMapCSSStyledObject *o1, OSPMapCSSStyledObject *o2)
                           {
							   float z1 = 0;
							   float z2 = 0;
							   if (o1->z == -1)
							   {
								   z1 = [[[[[[o1 style] objectForKey:@"z-index"] specifiers] objectAtIndex:0] sizeValue] value];
								   o1->z = z1;
								   
							   }
							   if (o2->z == -1)
							   {
								   z2 = [[[[[[o2 style] objectForKey:@"z-index"] specifiers] objectAtIndex:0] sizeValue] value];
								   o2->z = z2;
								   
							   }                               
							   return o1->z > o2->z ? NSOrderedDescending : z1 < z2 ? NSOrderedAscending : NSOrderedSame;
                           }]
                   forKey:layerNumber];
    }
    return layers;
}

- (void)renderLayers:(NSDictionary *)layers inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    for (NSNumber *layerNumber in [[layers allKeys] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSArray *layer = [layers objectForKey:layerNumber];
        
        NSMutableArray *ways         = [NSMutableArray arrayWithCapacity:[layer count]];
        NSMutableArray *nodesAndWays = [NSMutableArray arrayWithCapacity:[layer count]];
        for (OSPMapCSSStyledObject *styledObject in layer)
        {
            switch ([[styledObject object] memberType])
            {
                case OSPMemberTypeWay:
                    [ways addObject:styledObject];
                case OSPMemberTypeNode:
                    [nodesAndWays addObject:styledObject];
                    break;
                default:
                    break;
            }
        }
        
        [self renderWayFills:  ways inContext:ctx withScaleMultiplier:scale];
        [self renderWayCasings:ways inContext:ctx withScaleMultiplier:scale];
        [self renderLayerObjects:nodesAndWays inContext:ctx withScaleMultiplier:scale];
        [self renderLayerLabels: nodesAndWays inContext:ctx withScaleMultiplier:scale];
    }
}

- (void)renderWayFills:(NSArray *)ways inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    for (OSPMapCSSStyledObject *styledObject in ways)
    {
        [self renderWayFill:styledObject inContext:ctx withScaleMultiplier:scale];
    }
}

- (void)renderWayCasings:(NSArray *)ways inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    for (OSPMapCSSStyledObject *styledObject in ways)
    {
        [self renderCasing:styledObject inContext:ctx withScaleMultiplier:scale];
    }
}

- (void)renderLayerObjects:(NSArray *)layer inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    for (OSPMapCSSStyledObject *styledObject in layer)
    {
        switch ([[styledObject object] memberType])
        {
            case OSPMemberTypeWay:
                [self renderWay:styledObject inContext:ctx withScaleMultiplier:scale];
                break;
            case OSPMemberTypeNode:
                [self renderNode:styledObject inContext:ctx withScaleMultiplier:scale];
                break;
            default:
                break;
        }
    }
}

- (void)renderLayerLabels:(NSArray *)layer inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    for (OSPMapCSSStyledObject *styledObject in layer)
    {
        switch ([[styledObject object] memberType])
        {
            case OSPMemberTypeWay:
                [self renderWayLabel:styledObject inContext:ctx withScaleMultiplier:scale];
                break;
            case OSPMemberTypeNode:
                [self renderNodeLabel:styledObject inContext:ctx withScaleMultiplier:scale];
                break;
            default:
                break;
        }
    }
}

- (void)renderWayFill:(OSPMapCSSStyledObject *)object inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];
//    NSArray *nodes = [way nodeObjects];

    UIColor *fillColour = [self colourWithColourSpecifierList:[style objectForKey:@"fill-color"] opacitySpecifierList:[style objectForKey:@"fill-opacity"]];
    UIImage *fillImage = [self imageWithSpecifierList:[style objectForKey:@"fill-image"]];
    
    BOOL fillValid = fillColour != nil || fillImage != nil;
    
    if (fillValid && way->cLength[0] > 0/*[nodes count] > 1*/)
    {
        CGPathRef path = [self newPathForWay:way];
        if (path != nil)
        {
            CGContextAddPath(ctx, path);
            //CGContextClip(ctx);
            
            if (fillColour != nil)
            {
                CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
                CGContextSetFillColorSpace(ctx, rgbSpace);
                CGColorSpaceRelease(rgbSpace);
                CGContextSetFillColorWithColor(ctx, [fillColour CGColor]);
            }
            else
            {
                CGSize s = [fillImage size];
                CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
                CGContextSetFillColorSpace(ctx, patternSpace);
                CGColorSpaceRelease(patternSpace);
                static const CGPatternCallbacks callbacks = { 0, &patternCallback, NULL };
                CGPatternRef pat = CGPatternCreate((__bridge void *)[NSDictionary dictionaryWithObjectsAndKeys:fillImage, @"I", [NSValue valueWithCGSize:s], @"s", nil], CGRectMake(0.0f, 0.0f, s.width, s.height), CGAffineTransformMakeScale(1.0, -1.0), s.width, s.height, kCGPatternTilingNoDistortion, true, &callbacks);
                CGFloat alpha = 1;
                CGContextSetFillPattern(ctx, pat, &alpha);
                CGPatternRelease(pat);
            }
            CGContextFillPath(ctx);
            
            CFRelease(path);
        }
    }
}

- (CGPathRef)newPathForWay:(OSPWay *)way;
{
	CGMutablePathRef path = nil;
    OSPCoordinate2D last_nl;
    last_nl.x = 0;
    last_nl.y = 0;
    for (int block = 0; block < way->cLength[0]; block++)
	{
		for (int node = 0; node < way->cLength[block+1]; node += 2)
		{
			long double lat = (long double)way->cNodes[block][node+1];
			long double lon = (long double)way->cNodes[block][node];
            
			OSPCoordinate2D nl = OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(lat, lon), _zoom, _x, _y);
            if (block == 0 && node == 0)
			{
                path = CGPathCreateMutable();
				CGPathMoveToPoint(path, nil, nl.x, nl.y);
			}
			else
			{
				  CGPathAddLineToPoint(path, nil, nl.x, nl.y);
			}
            last_nl = nl;
		}
	}
    return path;
}

- (void)renderCasing:(OSPMapCSSStyledObject *)object inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];
    
//    NSArray *nodes = [way nodes];
    OSPMapCSSSize *width = [[[[style objectForKey:@"width"] specifiers] objectAtIndex:0] sizeValue];
    OSPMapCSSSize *casingWidth = [[[[style objectForKey:@"casing-width"] specifiers] objectAtIndex:0] sizeValue];
    
    if (/*[nodes count] > 1 &&*/ nil != width && nil != casingWidth)
    {
        CGPathRef path = [self newPathForWay:way];
        CGContextAddPath(ctx, path);
		
        CGContextSetLineWidth(ctx, ([width value]/* / _factor*/ + [casingWidth value]) * scale / _factor);
        UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"casing-color"] opacitySpecifierList:[style objectForKey:@"casing-opacity"]];
        CGContextSetStrokeColorWithColor(ctx, colour == nil ? [[UIColor blackColor] CGColor] : [colour CGColor]);
        NSString *lineCapName = [[[[style objectForKey:@"casing-linecap"] specifiers] objectAtIndex:0] stringValue];
        CGContextSetLineCap(ctx, nil != lineCapName ? CGLineCapFromNSString(lineCapName) : kCGLineCapRound);
        NSString *lineJoinName = [[[[style objectForKey:@"casing-linejoin"] specifiers] objectAtIndex:0] stringValue];
        CGContextSetLineJoin(ctx, nil != lineJoinName ? CGLineJoinFromNSString(lineJoinName) : kCGLineJoinRound);
        
        OSPMapCSSSpecifierList *dashSpec = [style objectForKey:@"casing-dashes"];
        if (nil != dashSpec)
        {
            CGFloat *dashes = malloc([[dashSpec specifiers] count] * sizeof(CGFloat));
            int i = 0;
            for (OSPMapCSSSizeSpecifier *spec in [dashSpec specifiers])
            {
                OSPMapCSSSize *size = [spec sizeValue];
                if (nil != size)
                {
                    dashes[i] = [size value] * scale;
                    i++;
                }
            }
            CGContextSetLineDash(ctx, 0.0f, dashes, i);
            free(dashes);
        }
        else
        {
            CGContextSetLineDash(ctx, 0.0f, NULL, 0);
        }
        CGContextStrokePath(ctx);
        CFRelease(path);
    }
}

- (void)renderWay:(OSPMapCSSStyledObject *)object inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];

//    NSArray *nodes = [way nodeObjects];
    OSPMapCSSSize *width = [[[[style objectForKey:@"width"] specifiers] objectAtIndex:0] sizeValue];
    UIImage *strokeImage = [self imageWithSpecifierList:[style objectForKey:@"image"]];

    BOOL strokeValid = nil != width;
    
    if (/*[nodes count] > 1 &&*/ strokeValid)
    {
        CGPathRef path = [self newPathForWay:way];
        CGContextAddPath(ctx, path);
        
        CGContextSetLineWidth(ctx, [width value] * scale / _factor);
        NSString *lineCapName = [[[[style objectForKey:@"linecap"] specifiers] objectAtIndex:0] stringValue];
        CGContextSetLineCap(ctx, nil != lineCapName ? CGLineCapFromNSString(lineCapName) : kCGLineCapRound);
        NSString *lineJoinName = [[[[style objectForKey:@"linejoin"] specifiers] objectAtIndex:0] stringValue];
        CGContextSetLineJoin(ctx, nil != lineJoinName ? CGLineJoinFromNSString(lineJoinName) : kCGLineJoinRound);
        
        OSPMapCSSSpecifierList *dashSpec = [style objectForKey:@"dashes"];
        if (nil != dashSpec)
        {
            CGFloat *dashes = malloc([[dashSpec specifiers] count] * sizeof(CGFloat));
            int i = 0;
            for (OSPMapCSSSizeSpecifier *spec in [dashSpec specifiers])
            {
                OSPMapCSSSize *size = [spec sizeValue];
                if (nil != size)
                {
                    dashes[i] = [size value] * scale;
                    i++;
                }
            }
            CGContextSetLineDash(ctx, 0.0f, dashes, i);
            free(dashes);
        }
        else
        {
            CGContextSetLineDash(ctx, 0.0f, NULL, 0);
        }
        
        if (nil == strokeImage)
        {
            CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
            CGContextSetFillColorSpace(ctx, rgbSpace);
            CGColorSpaceRelease(rgbSpace);
            UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"color"] opacitySpecifierList:[style objectForKey:@"opacity"]];
            CGContextSetStrokeColorWithColor(ctx, colour == nil ? [[UIColor blackColor] CGColor] : [colour CGColor]);
        }
        else
        {
            CGSize s = [strokeImage size];
            CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
            CGContextSetStrokeColorSpace(ctx, patternSpace);
            CGColorSpaceRelease(patternSpace);
            static const CGPatternCallbacks callbacks = { 0, &patternCallback, NULL };
            CGPatternRef pat = CGPatternCreate((__bridge void *)[NSDictionary dictionaryWithObjectsAndKeys:strokeImage, @"I", [NSValue valueWithCGSize:s], @"s", nil], CGRectMake(0.0f, 0.0f, s.width, s.height), CGAffineTransformMakeScale(1.0, -1.0), s.width, s.height, kCGPatternTilingNoDistortion, true, &callbacks);
            CGFloat alpha = 1;
            CGContextSetStrokePattern(ctx, pat, &alpha);
            CGPatternRelease(pat);
        }
		CGContextStrokePath(ctx);
		CGPathRelease(path);
    }
}

- (void)renderNode:(OSPMapCSSStyledObject *)node inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    [self renderObject:node atPoint:[(OSPNode *)[node object] projectedLocation] inContext:ctx withScaleMultiplier:scale];
}

- (void)renderObjectAtCentroid:(OSPMapCSSStyledObject *)object inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [object style];
    if (nil != [self imageWithSpecifierList:[style objectForKey:@"icon-image"]])
    {
        OSPWay *way = (OSPWay *)[object object];
        OSPCoordinate2D c = [way projectedCentroid];
        [self renderObject:object atPoint:c inContext:ctx withScaleMultiplier:scale];
    }
}

- (void)renderObject:(OSPMapCSSStyledObject *)object atPoint:(OSPCoordinate2D)loc inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [object style];
    
    UIImage *image = [self imageWithSpecifierList:[style objectForKey:@"icon-image"]];
    if (nil != image)
    {
        OSPMapCSSSize *opacity = [[[[style objectForKey:@"icon-opacity"] specifiers] objectAtIndex:0] sizeValue];
        CGContextSaveGState(ctx);
        CGContextSetAlpha(ctx, nil == opacity ? 1.0f : [opacity value]);
        OSPMapCSSSize *widthSize = [[[[style objectForKey:@"icon-width"] specifiers] objectAtIndex:0] sizeValue];
        OSPMapCSSSize *heightSize = [[[[style objectForKey:@"icon-height"] specifiers] objectAtIndex:0] sizeValue];
        
        CGFloat width = [image size].width;
        CGFloat height = [image size].height;
        
        if (nil != widthSize)
        {
            width = [widthSize unit] == OSPMapCSSUnitPercent ? width * [widthSize value] * 0.01f : [widthSize value];
        }
        if (nil != heightSize)
        {
            height = [heightSize unit] == OSPMapCSSUnitPercent ? height * [heightSize value] * 0.01f : [heightSize value];
        }
        width *= scale;
        height *= scale;
        
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, CGRectMake(loc.x - width * 0.5f, -loc.y - height * 0.5f, width, height), [image CGImage]);
        CGContextRestoreGState(ctx);
    }
}

- (void)renderWayLabel:(OSPMapCSSStyledObject *)styledWay inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    if (_zoom > 16) [self renderObjectAtCentroid:styledWay inContext:ctx withScaleMultiplier:scale];

	scale = 1.5/_scale;

    NSDictionary *style = [styledWay style];
    OSPWay *way = (OSPWay *)[styledWay object];
    
    NSString *untransformedTitle = way->name;//[[[[style objectForKey:@"text"] specifiers] objectAtIndex:0] stringValue];
    NSString *title = [self applyTextTransform:style toString:untransformedTitle];

    if (nil != [[[[style objectForKey:@"text"] specifiers] objectAtIndex:0] stringValue] && title != nil)
    {
        NSString *position = [[[[style objectForKey:@"text-position"] specifiers] objectAtIndex:0] stringValue];
        position = position ?: @"center";

        if ([position isEqualToString:@"line"])
        {

            [self drawText:title onWay:way inContext:ctx withStyle:style scaleMultiplier:scale];
        }
        else if ([position isEqualToString:@"center"])
        {
			OSPCoordinate2D c = way->labelPosition == nil ? [way projectedCentroid] : OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(way->labelPosition[1],way->labelPosition[0]), _zoom, _x, _y);
            CGPoint textPosition = CGPointMake(c.x, c.y);
            
            [self drawText:title atPoint:textPosition inContext:ctx withStyle:style scaleMultiplier:scale];
        }
    }
}

- (void)renderNodeLabel:(OSPMapCSSStyledObject *)styledNode inContext:(CGContextRef)ctx withScaleMultiplier:(CGFloat)scale
{
    NSDictionary *style = [styledNode style];
    OSPNode *node = (OSPNode *)[styledNode object];
    
    NSString *untransformedTitle = [[[[style objectForKey:@"text"] specifiers] objectAtIndex:0] stringValue];
    NSString *title = [self applyTextTransform:style toString:untransformedTitle];
    
    if (nil != title)
    {
        OSPCoordinate2D c = [node projectedLocation];
        CGPoint textPosition = CGPointMake(c.x, c.y);
        
        [self drawText:title atPoint:textPosition inContext:ctx withStyle:style scaleMultiplier:scale];
    }
}

- (NSString *)applyTextTransform:(NSDictionary *)style toString:(NSString *)str
{
    NSString *textTransform = [[[[style objectForKey:@"text-transform"] specifiers] objectAtIndex:0] stringValue];
    if ([textTransform isEqualToString:@"uppercase"])
    {
        return [str uppercaseString];
    }
    else if ([textTransform isEqualToString:@"lowercase"])
    {
        return [str lowercaseString];
    }
    else if ([textTransform isEqualToString:@"capitalize"])
    {
        return [str capitalizedString];
    }
    return str;
}

- (void)drawText:(NSString *)text atPoint:(CGPoint)textPosition inContext:(CGContextRef)ctx withStyle:(NSDictionary *)style scaleMultiplier:(CGFloat)scale
{
    CTFontRef scaledFont = nil;
    CTFontRef font = [self createFontWithStyle:style scaledVariant:&scaledFont atScale:scale];
    
    OSPMapCSSSize *haloSize = [[[[style objectForKey:@"text-halo-radius"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat haloRadius = nil == haloSize ? 0.0f : [haloSize value];
    BOOL hasHalo = haloRadius != 0.0f;
    
    CGFloat lineHeight = CTFontGetAscent(scaledFont) + CTFontGetDescent(scaledFont) + CTFontGetLeading(scaledFont) + haloRadius * scale;
    
    UIColor *haloColour = [self colourWithColourSpecifierList:[style objectForKey:@"text-halo-color"] opacitySpecifierList:[style objectForKey:@"text-halo-opacity"]];
    UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"text-color"] opacitySpecifierList:[style objectForKey:@"text-opacity"]];
    
    OSPMapCSSSize *vOffsetSize = [[[[style objectForKey:@"text-offset"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat offset = nil == vOffsetSize ? 0.0f : [vOffsetSize value];
    CGFloat scaledOffset = offset * scale;
    
    OSPMapCSSSize *widthSize = [[[[style objectForKey:@"max-width"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat width = nil == widthSize ? 100.0f : [widthSize value];
    
    CGFloat scaledWidth = width * scale;
    
    textPosition.y += scaledOffset;
    
    const CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    const CTParagraphStyleSetting paragraphStyleSettings[] = {{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(lineBreakMode), .value = &lineBreakMode}};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyleSettings, sizeof(paragraphStyleSettings) / sizeof(paragraphStyleSettings[0]));
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)font, kCTFontAttributeName,
                                (__bridge id)paragraphStyle, kCTParagraphStyleAttributeName,
                                nil];
    NSMutableDictionary *scaledAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             (__bridge id)scaledFont, kCTFontAttributeName,
                                             kCFBooleanTrue, kCTForegroundColorFromContextAttributeName,
                                             (__bridge id)paragraphStyle, kCTParagraphStyleAttributeName,
                                             nil];
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)text, (__bridge CFDictionaryRef)attributes);
    CFAttributedStringRef scaledAttrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)text, (__bridge CFDictionaryRef)scaledAttributes);
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(attrString);
    CTTypesetterRef scaledTypesetter = CTTypesetterCreateWithAttributedString(scaledAttrString);
    CFRelease(attrString);
    CFRelease(scaledAttrString);
    
    NSString *textDecoration = [[[[style objectForKey:@"text-decoration"] specifiers] objectAtIndex:0] stringValue];
    BOOL shouldUnderline = [textDecoration isEqualToString:@"underline"];
    CGFloat halfDescent = CTFontGetDescent(scaledFont) * 0.5f;
    
    CFIndex start = 0;
    CFIndex length = [text length];
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetLineWidth(ctx, haloRadius * 2.0f * scale);
    CGContextSetFillColorWithColor(ctx, [colour CGColor]);
    CGContextSetStrokeColorWithColor(ctx, [haloColour CGColor]);
    do
    {
        CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, width);
        
        CTLineRef line = CTTypesetterCreateLine(scaledTypesetter, CFRangeMake(start, count));
        CGFloat penOffset = CTLineGetPenOffsetForFlush(line, 0.5f, scaledWidth);
        CGContextSetTextPosition(ctx, textPosition.x - scaledWidth * 0.5f + penOffset, textPosition.y);
        
        if (hasHalo)
        {
            CGContextSetTextDrawingMode(ctx, kCGTextStroke);
            CTLineDraw(line, ctx);
            CGContextSetTextDrawingMode(ctx, kCGTextFill);
            CGContextSetTextPosition(ctx, textPosition.x - scaledWidth * 0.5f + penOffset, textPosition.y);
        }
        
        if (shouldUnderline)
        {
            CGRect underlineRect = CGRectMake(textPosition.x - scaledWidth * 0.5f + penOffset, textPosition.y + halfDescent, scaledWidth - 2.0f * penOffset, scale);
            CGContextStrokeRect(ctx, underlineRect);
            CGContextFillRect(ctx, underlineRect);
        }
        
        CTLineDraw(line, ctx);
        
        CFRelease(line);
        
        textPosition.y += lineHeight;
        
        start += count;
    }
    while (start < length);
    CFRelease(typesetter);
    
    CFRelease(font);
    CFRelease(scaledFont);
}

- (void)drawText:(NSString *)text onWay:(OSPWay *)textWay inContext:(CGContextRef)ctx withStyle:(NSDictionary *)style scaleMultiplier:(CGFloat)scale
{
	static int oldZoom = 0;
    static CTFontRef scaledFont = nil;
    static CTFontRef font = nil;
	
	if (oldZoom != _zoom || font == nil) font = [self createFontWithStyle:style scaledVariant:&scaledFont atScale:scale];
	oldZoom = _zoom;
	
    OSPMapCSSSize *haloSize = [[[[style objectForKey:@"text-halo-radius"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat haloRadius = nil == haloSize ? 0.0f : [haloSize value];
    BOOL hasHalo = haloRadius != 0.0f;
    
    UIColor *haloColour = [self colourWithColourSpecifierList:[style objectForKey:@"text-halo-color"] opacitySpecifierList:[style objectForKey:@"text-halo-opacity"]];
    UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"text-color"] opacitySpecifierList:[style objectForKey:@"text-opacity"]];
    
    OSPMapCSSSize *vOffsetSize = [[[[style objectForKey:@"text-offset"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat offset = nil == vOffsetSize ? 0.0f : [vOffsetSize value];
    CGFloat scaledOffset = offset * scale;

    NSMutableDictionary *scaledAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             (__bridge id)scaledFont, kCTFontAttributeName,
                                             kCFBooleanTrue, kCTForegroundColorFromContextAttributeName,
                                             nil];
    
    CFAttributedStringRef scaledAttrString = CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)text, (__bridge CFDictionaryRef)scaledAttributes);
    CTTypesetterRef scaledTypesetter = CTTypesetterCreateWithAttributedString(scaledAttrString);
    CTLineRef line = CTTypesetterCreateLine(scaledTypesetter, CFRangeMake(0, CFAttributedStringGetLength(scaledAttrString)));
	
    CFRelease(scaledAttrString);
    
    double lineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    
    CGContextSetLineWidth(ctx, haloRadius * 2.0f * scale);
    CGContextSetFillColorWithColor(ctx, [colour CGColor]);
    CGContextSetStrokeColorWithColor(ctx, [haloColour CGColor]);
    
    CGFontRef gFont = CTFontCopyGraphicsFont(scaledFont, NULL);
    CGContextSetFont(ctx, gFont);
    CGContextSetFontSize(ctx, CTFontGetSize(scaledFont));
    CFRelease(gFont);

    double wayOffset = [textWay textOffsetForTextWidth:lineWidth];

    if (wayOffset > 0)
    {
        BOOL backwards = [textWay positionOnWayWithOffset:wayOffset heightAboveWay:0.0 backwards:NO].x > [textWay positionOnWayWithOffset:wayOffset + lineWidth heightAboveWay:0.0 backwards:NO].x;
		[names addObject:text];
//		if (backwards) return;
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        long numRuns = CFArrayGetCount(runs);
        for (long runNumber = 0; runNumber < numRuns; runNumber++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runNumber);
			CFDictionaryRef attrs = CTRunGetAttributes(run);
			CTFontRef f = CFDictionaryGetValue(attrs, kCTFontAttributeName);
			if (NULL != f)
			{
				CGFontRef gf = CTFontCopyGraphicsFont(f, NULL);
				CGContextSetFont(ctx, gf);
                CFRelease(gf);
			}
            CFIndex numGlyphs = CTRunGetGlyphCount(run);
            const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
            const CGPoint *glyphOffsets = CTRunGetPositionsPtr(run);
            
            if (glyphOffsets == NULL) return;      // FAilcheck
            
            OSPCoordinate2D *glyphPositions = malloc((numGlyphs + 1) * sizeof(OSPCoordinate2D));
            CGFloat *glyphAngles = malloc(numGlyphs * sizeof(CGFloat));
            
            CGPoint currentGlyphOffset;
            for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
            {
                currentGlyphOffset = glyphOffsets[glyphNumber];
                glyphPositions[glyphNumber] = [textWay positionOnWayWithOffset:wayOffset + currentGlyphOffset.x heightAboveWay:currentGlyphOffset.y - scaledOffset backwards:backwards];
            }
            glyphPositions[numGlyphs] = [textWay positionOnWayWithOffset:wayOffset + lineWidth heightAboveWay:-scaledOffset backwards:backwards];
            OSPCoordinate2D currentGlyphPosition = glyphPositions[0];
            for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
            {
                OSPCoordinate2D nextGlyphPosition = glyphPositions[glyphNumber+1];
                
                double dx = nextGlyphPosition.x - currentGlyphPosition.x;
                double dy = nextGlyphPosition.y - currentGlyphPosition.y;
                glyphAngles[glyphNumber] = dx > 0.0 ? (dy > 0.0 ? atan(dy / dx) : -atan(-dy / dx))
                : dx < 0.0 ? (dy > 0.0 ? M_PI - atan(dy / -dx) : M_PI + atan(-dy / -dx))
                :            (dy < 0.0 ? 3 * M_PI_2 : M_PI_2);
                
                
                currentGlyphPosition = nextGlyphPosition;
            }
            @try {
            if (hasHalo)
            {
                CGContextSetTextDrawingMode(ctx, kCGTextStroke);
                for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
                {
                    CGGlyph glyph = glyphs[glyphNumber];
                    OSPCoordinate2D p = glyphPositions[glyphNumber];
                    
                    CGContextSetTextMatrix(ctx, CGAffineTransformConcat(CGAffineTransformMakeRotation(-glyphAngles[glyphNumber]), CGAffineTransformMakeScale(1.0, -1.0)));
                    CGContextSetTextPosition(ctx, p.x, p.y);
                    CGContextShowGlyphs(ctx, &glyph, 1);
                }
            }
            CGContextSetTextDrawingMode(ctx, kCGTextFill);
            for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
            {
                CGGlyph glyph = glyphs[glyphNumber];
                OSPCoordinate2D p = glyphPositions[glyphNumber];
                
                CGContextSetTextMatrix(ctx, CGAffineTransformConcat(CGAffineTransformMakeRotation(-glyphAngles[glyphNumber]), CGAffineTransformMakeScale(1.0, -1.0)));
                CGContextSetTextPosition(ctx, p.x, p.y);
                CGContextShowGlyphs(ctx, &glyph, 1);
            }
            }
            @catch (NSException * e) {
                //Nothing
            }
            free(glyphPositions);
            free(glyphAngles);
        }
    }

    CFRelease(line);
    CFRelease(scaledTypesetter);
//    CFRelease(scaledFont);
//    CFRelease(font);
}

- (CTFontRef)createFontWithStyle:(NSDictionary *)style scaledVariant:(CTFontRef *)scaledFont atScale:(CGFloat)scale
{
    NSString *fontFamily = [[[[style objectForKey:@"font-family"] specifiers] objectAtIndex:0] stringValue];
    fontFamily = fontFamily ?: @"Helvetica";
    OSPMapCSSSize *fontSizeSpec = [[[[style objectForKey:@"font-size"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat fontSize = nil == fontSizeSpec ? 12.0f : [fontSizeSpec value];
    
    CTFontSymbolicTraits traits = 0x0;
    NSString *fontWeight = [[[[style objectForKey:@"font-weight"] specifiers] objectAtIndex:0] stringValue];
    NSString *fontStyle = [[[[style objectForKey:@"font-style"] specifiers] objectAtIndex:0] stringValue];
    traits |= [fontWeight isEqualToString:@"bold"] ? kCTFontBoldTrait : 0x0;
    traits |= [fontStyle isEqualToString:@"italic"] ? kCTFontItalicTrait : 0x0;
    CTFontSymbolicTraits newTraits = traits;
    
    CTFontRef baseFont = CTFontCreateWithName((__bridge CFStringRef)fontFamily, fontSize, NULL);
    CTFontRef font = CTFontCreateCopyWithSymbolicTraits(baseFont, fontSize, NULL, newTraits, newTraits);
    if (NULL == font)
    {
        newTraits &= (0xffffffff ^ kCTFontItalicTrait);
        font = CTFontCreateCopyWithSymbolicTraits(baseFont, fontSize, NULL, newTraits, newTraits);
    }
    if (NULL == font)
    {
        newTraits = traits & (0xffffffff ^ kCTFontBoldTrait);
        font = CTFontCreateCopyWithSymbolicTraits(baseFont, fontSize, NULL, newTraits, newTraits);
    }
    if (NULL == font)
    {
        newTraits = 0x0;
        font = CTFontCreateCopyWithSymbolicTraits(baseFont, fontSize, NULL, newTraits, newTraits);
    }
    *scaledFont = CTFontCreateCopyWithSymbolicTraits(baseFont, fontSize * scale, NULL, newTraits, newTraits);
    CFRelease(baseFont);
    
    return font;
}

- (UIImage *)imageWithSpecifierList:(OSPMapCSSSpecifierList *)spec
{
    if (nil != spec)
    {
        OSPMapCSSUrl *u = [[[spec specifiers] objectAtIndex:0] urlValue];
        NSURL *url = [u content];
        //NSString *urlString = [url relativeString];
        NSString *ext = [url pathExtension];
        NSString *resName = [[url lastPathComponent] stringByDeletingPathExtension];
        //NSString *dir = [urlString stringByDeletingLastPathComponent];
        NSString *path = [[NSBundle mainBundle] pathForResource:resName ofType:ext];// inDirectory:dir];
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}


@end

void patternCallback(void *info, CGContextRef ctx)
{
    NSDictionary *i = (__bridge NSDictionary *)info;
    UIImage *image = [i objectForKey:@"I"];
    CGSize s = [[i objectForKey:@"s"] CGSizeValue];
    CGImageRef imageRef = [image CGImage];
    CGContextDrawImage(ctx, CGRectMake(0.0f, 0.0f, s.width, s.height), imageRef);
}
