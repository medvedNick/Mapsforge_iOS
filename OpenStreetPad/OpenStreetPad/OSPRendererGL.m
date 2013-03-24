//
//  OSPRenderer.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/29/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPRendererGL.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import <GLKit/GLKit.h>

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

#import "Texture2D.h"

@interface OSPRendererGL()
{
	OSPMapArea mapArea;
	NSMutableSet *names;
	OSPMapLoader *mapLoader;
	
	double scale;
	double _scale;
	CGFloat _zoom;
	CGFloat _factor;
	
	EAGLContext* myContext;
	GLuint framebuffer;
	GLuint colorRenderbuffer;
	GLuint depthRenderbuffer;
	GLuint _vertexArray;
    GLuint _vertexBuffer;
	GLuint resolveFramebuffer;
	GLuint msaaFramebuffer, msaaRenderbuffer, msaaDepthbuffer;
}

- (void)setupOpenGL;

- (NSDictionary *)sortedObjects:(NSArray *)objects;

- (UIColor *)colourWithColourSpecifierList:(OSPMapCSSSpecifierList *)colour opacitySpecifierList:(OSPMapCSSSpecifierList *)opacity;
- (UIImage *)imageWithSpecifierList:(OSPMapCSSSpecifierList *)spec;

- (NSString *)applyTextTransform:(NSDictionary *)style toString:(NSString *)str;

- (void)renderLayers:(NSDictionary *)layers;

- (void)renderWayFills:(NSArray *)ways;
- (void)renderWayCasings:(NSArray *)ways;
- (void)renderLayerObjects:(NSArray *)layer;
- (void)renderLayerLabels:(NSArray *)layer;

- (void)renderWayFill:(OSPMapCSSStyledObject *)way;
- (void)renderWay:(OSPMapCSSStyledObject *)way;
- (void)renderCasing:(OSPMapCSSStyledObject *)way;
- (void)renderNode:(OSPMapCSSStyledObject *)node;
- (void)renderObjectAtCentroid:(OSPMapCSSStyledObject *)object;
- (void)renderObject:(OSPMapCSSStyledObject *)obj atPoint:(OSPCoordinate2D)loc;

- (void)renderWayLabel:(OSPMapCSSStyledObject *)styledWay;
- (void)renderNodeLabel:(OSPMapCSSStyledObject *)styledWay;

- (void)drawText:(NSString *)text atPoint:(CGPoint)textPosition withStyle:(NSDictionary *)style;
- (void)drawText:(NSString *)text onWay:(OSPWay *)textWay withStyle:(NSDictionary *)style;

- (CGFloat *)createPathForWay:(OSPWay *)way length:(NSInteger*)length;

@end;

@implementation OSPRendererGL

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
		myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		[EAGLContext setCurrentContext:myContext];
		[self setupOpenGL];
		[EAGLContext setCurrentContext:nil];
		objectsNumber = 0;
	}
	return self;
}

- (UIImage*) imageForTileX:(int)x Y:(int)y zoom:(int)zoom
{
	@synchronized(self)
	{
		_zoom = zoom;
		[names removeAllObjects];
		mapLoader.mapArea = mapArea;
		[mapLoader executeQueryForTileX:x Y:y Zoom:zoom];
		
		objectsNumber = mapLoader.mapObjects.count;
		
		switch (zoom) {
			case 18:
				_factor = 1;
				break;
			case 17:
				_factor = 1;
				break;
			case 16:
				_factor = 1.5;
				break;
			case 15:
				_factor = 2;
				break;
			case 14:
				_factor = 4;
				break;
			case 13:
				_factor = 6;
			case 12:
				_factor = 8;
			default:
				_factor = 10;
				break;
		}
		
		UIImage *image = [self renderImageAtZoom:zoom];
		return image;
	}
}

-(void) setupOpenGL
{
	int width = 256;
	int height = 256;
	
	glGenFramebuffersOES(1, &framebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
	
	glGenRenderbuffersOES(1, &colorRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, width, height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
	
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, width, height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) ;
	if(status != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", status);
	}
	
	glGenFramebuffersOES(1, &msaaFramebuffer); 
	glGenRenderbuffersOES(1, &msaaRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer); 
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderbuffer);   
	
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_RGBA8_OES, width, height); 
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, msaaRenderbuffer); 
	
	glGenRenderbuffersOES(1, &msaaDepthbuffer);   
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaDepthbuffer); 
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_DEPTH_COMPONENT16_OES, width, height); 
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, msaaDepthbuffer);

}

- (UIImage *) renderImageAtZoom:(int)zoom
{
	int width = 256;
	int height = 256;
	
	CGRect b = CGRectMake(0, 0, width, height);
	OSPCoordinateRect r = OSPRectForMapAreaInRect([self mapArea], b);
	
	_scale = b.size.width / r.size.x;
	scale = 1.0/_scale;
	
	[EAGLContext setCurrentContext:myContext];

	glBindFramebuffer(GL_FRAMEBUFFER_OES, msaaFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderbuffer);
	
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0.0f, 256.0f, 256.0f, 0.0f, 1.0f, -1.0f);
    glMatrixMode(GL_MODELVIEW);

	glPushMatrix();

	glScalef(_scale, _scale, 1);
	glTranslatef(-r.origin.x, -r.origin.y, 0);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_BLEND);

	
	NSDictionary *canvasStyle = [stylesheet styleForCanvasAtZoom:zoom];
    UIColor *c = [self colourWithColourSpecifierList:[canvasStyle objectForKey:@"fill-color"] opacitySpecifierList:[canvasStyle objectForKey:@"fill-opacity"]];
	
	CGFloat red, green, blue, alpha;
	[c getRed:&red green:&green blue:&blue alpha:&alpha];
	
	glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	NSArray *styledObjects = [[self stylesheet] styledObjects:mapLoader.mapObjects atZoom:zoom];
	NSLog(@"loaded: %d, styled: %d", mapLoader.mapObjects.count, styledObjects.count);
	
	NSDictionary *sortedObjects = [self sortedObjects:styledObjects];
	[self renderLayers:sortedObjects];
	
	glPopMatrix();
	
	// msaa
	
	glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer); 
	glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, framebuffer);
	
	glResolveMultisampleFramebufferAPPLE();

	glBindFramebuffer(GL_FRAMEBUFFER_OES, framebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER, colorRenderbuffer);

	// grabbing image from FBO
	
	GLint backingWidth, backingHeight;
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	NSInteger x = 0, y = 0;//, width = backingWidth, height = backingHeight;
	NSInteger dataLength = width * height * 4;
	GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
	
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
									ref, NULL, true, kCGRenderingIntentDefault);
	
	
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef cgcontext = UIGraphicsGetCurrentContext();
	CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
	CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, width, height), iref);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	free(data);
	CFRelease(ref);
	CFRelease(colorspace);
	CGImageRelease(iref);
	
	[EAGLContext setCurrentContext:nil];
	
	return image;
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
							   float z1;
							   float z2;
							   if (o1->z == 0)
							   {
								   z1 = [[[[[[o1 style] objectForKey:@"z-index"] specifiers] objectAtIndex:0] sizeValue] value];
								   o1->z = z1;
								   
							   }
							   if (o2->z == 0)
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

- (void)renderLayers:(NSDictionary *)layers
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
        
        [self renderWayFills:  ways];
        [self renderWayCasings:ways];
        [self renderLayerObjects:nodesAndWays];
        [self renderLayerLabels: nodesAndWays];
    }
}

- (void)renderWayFills:(NSArray *)ways
{
    for (OSPMapCSSStyledObject *styledObject in ways)
    {
        [self renderWayFill:styledObject];
    }
}

- (void)renderWayCasings:(NSArray *)ways
{
    for (OSPMapCSSStyledObject *styledObject in ways)
    {
        [self renderCasing:styledObject];
    }
}

- (void)renderLayerObjects:(NSArray *)layer
{
    for (OSPMapCSSStyledObject *styledObject in layer)
    {
        switch ([[styledObject object] memberType])
        {
            case OSPMemberTypeWay:
                [self renderWay:styledObject];
                break;
            case OSPMemberTypeNode:
                [self renderNode:styledObject];
                break;
            default:
                break;
        }
    }
}

- (void)renderLayerLabels:(NSArray *)layer
{
    for (OSPMapCSSStyledObject *styledObject in layer)
    {
        switch ([[styledObject object] memberType])
        {
            case OSPMemberTypeWay:
                [self renderWayLabel:styledObject];
                break;
            case OSPMemberTypeNode:
                [self renderNodeLabel:styledObject];
                break;
            default:
                break;
        }
    }
}

- (void)renderWayFill:(OSPMapCSSStyledObject *)object
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];

	
    UIColor *fillColour = [self colourWithColourSpecifierList:[style objectForKey:@"fill-color"] opacitySpecifierList:[style objectForKey:@"fill-opacity"]];
    UIImage *fillImage = nil;//[self imageWithSpecifierList:[style objectForKey:@"fill-image"]];
    
    BOOL fillValid = fillColour != nil || fillImage != nil;
    
    if (fillValid && way->cLength[0] > 0)
    {
		NSInteger length;
		CGFloat *path = [self createPathForWay:way length:&length];
		glLineWidth(1);
		
		glVertexPointer(2, GL_FLOAT, 0, path);
		
        if (fillColour != nil)
        {
			CGFloat red, green, blue, alpha;
			[fillColour getRed:&red green:&green blue:&blue alpha:&alpha];
			glColor4f(red, green, blue, 1.0f);			
        }
        else
        {

        }

		glDrawArrays(GL_TRIANGLE_FAN, 0, length);
		
		free(path);
		
    }
}

- (void)renderCasing:(OSPMapCSSStyledObject *)object
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];
    
    OSPMapCSSSize *width = [[[[style objectForKey:@"width"] specifiers] objectAtIndex:0] sizeValue];
    OSPMapCSSSize *casingWidth = [[[[style objectForKey:@"casing-width"] specifiers] objectAtIndex:0] sizeValue];
    
    if (nil != width && nil != casingWidth)
    {
		NSInteger length;
		CGFloat *path = [self createPathForWay:way length:&length];
		glLineWidth(([width value] + [casingWidth value]) / _factor);

        UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"casing-color"] opacitySpecifierList:[style objectForKey:@"casing-opacity"]];
		CGFloat red, green, blue, alpha;
		[colour getRed:&red green:&green blue:&blue alpha:&alpha];
		glColor4f(red, green, blue, 1.0f);
		glVertexPointer(2, GL_FLOAT, 0, path);
	
		glDrawArrays(GL_LINE_STRIP, 0, length);
		
		free(path);
	}
}

- (void)renderWay:(OSPMapCSSStyledObject *)object
{
    NSDictionary *style = [object style];
    OSPWay *way = (OSPWay *)[object object];
	
    OSPMapCSSSize *width = [[[[style objectForKey:@"width"] specifiers] objectAtIndex:0] sizeValue];
    UIImage *strokeImage = nil;//[self imageWithSpecifierList:[style objectForKey:@"image"]];
	
    BOOL strokeValid = nil != width;
    
    if (strokeValid)
    {
		NSInteger length;
		CGFloat *path = [self createPathForWay:way length:&length];
		glLineWidth([width value] / _factor);
		
		UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"color"] opacitySpecifierList:[style objectForKey:@"opacity"]];
		CGFloat red, green, blue, alpha;
		[colour getRed:&red green:&green blue:&blue alpha:&alpha];
		if (colour == nil)
		{
			red = green = blue = 0.0f;
		}
		
		glColor4f(red, green, blue, 1.0f);
		


		CGFloat *caps = (CGFloat*)malloc(4*sizeof(CGFloat));
		
		caps[0] = path[0];
		caps[1] = path[1];
		caps[2] = path[length-2];
		caps[3] = path[length-1];
		
//		glPointSize([width value] / _factor);
//		glVertexPointer(2, GL_FLOAT, 0, caps);
//		glDrawArrays(GL_POINTS, 0, 0);		

		glVertexPointer(2, GL_FLOAT, 0, path);
		glDrawArrays(GL_LINE_STRIP, 0, length);
		
		free(path);
		free(caps);
    }
	
}

- (void)renderNode:(OSPMapCSSStyledObject *)node
{
    [self renderObject:node atPoint:[(OSPNode *)[node object] projectedLocation]];
}

- (void)renderObjectAtCentroid:(OSPMapCSSStyledObject *)object
{
    NSDictionary *style = [object style];
    if (nil != [self imageWithSpecifierList:[style objectForKey:@"icon-image"]])
    {
        OSPWay *way = (OSPWay *)[object object];
        OSPCoordinate2D c = [way projectedCentroid];
        [self renderObject:object atPoint:c];
    }
}

- (void)renderObject:(OSPMapCSSStyledObject *)object atPoint:(OSPCoordinate2D)loc
{
    NSDictionary *style = [object style];
    
    UIImage *image = [self imageWithSpecifierList:[style objectForKey:@"icon-image"]];
    if (nil != image)
    {

    }
}

- (void)renderWayLabel:(OSPMapCSSStyledObject *)styledWay
{
    if (_zoom > 16) [self renderObjectAtCentroid:styledWay];
	
    NSDictionary *style = [styledWay style];
    OSPWay *way = (OSPWay *)[styledWay object];
    
    NSString *untransformedTitle = way->name;
    NSString *title = [self applyTextTransform:style toString:untransformedTitle];
	
    if (nil != [[[[style objectForKey:@"text"] specifiers] objectAtIndex:0] stringValue] && title != nil)
    {
        NSString *position = [[[[style objectForKey:@"text-position"] specifiers] objectAtIndex:0] stringValue];
        position = @"center";//position ?: @"center";
		
        if ([position isEqualToString:@"line"])
        {
            [self drawText:title onWay:way withStyle:style];
        }
        else if ([position isEqualToString:@"center"])
        {
			OSPCoordinate2D c = way->labelPosition == nil ? [way projectedCentroid] : OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(way->labelPosition[1],way->labelPosition[0]));
            CGPoint textPosition = CGPointMake(c.x, c.y);
            
            [self drawText:title atPoint:textPosition withStyle:style];
        }
    }
}

- (void)renderNodeLabel:(OSPMapCSSStyledObject *)styledNode
{
    NSDictionary *style = [styledNode style];
    OSPNode *node = (OSPNode *)[styledNode object];
    
    NSString *untransformedTitle = [[[[style objectForKey:@"text"] specifiers] objectAtIndex:0] stringValue];
    NSString *title = [self applyTextTransform:style toString:untransformedTitle];
    
    if (nil != title)
    {
        OSPCoordinate2D c = [node projectedLocation];
        CGPoint textPosition = CGPointMake(c.x, c.y);
        
        [self drawText:title atPoint:textPosition withStyle:style];
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

- (void)drawText:(NSString *)text atPoint:(CGPoint)textPosition withStyle:(NSDictionary *)style
{
	return;
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	for (int i = 0; i < 1/*text.length*/; i++)
	{
		unichar ch = [text characterAtIndex:i];
		CGSize size = CGSizeMake(16, 16);
		glColor4f(0, 0, 0, 255);
		Texture2D *charTex = [[Texture2D alloc] initWithString:@"N" dimensions:size alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:10.0f];
		
//		CGPoint charPosition = CGPointMake(, );
		[charTex drawInRect:CGRectMake(textPosition.x, textPosition.y, size.width*scale, size.height*scale)];
	}
	glDisable(GL_TEXTURE_2D);
}

- (void)drawText:(NSString *)text onWay:(OSPWay *)textWay withStyle:(NSDictionary *)style
{
    OSPMapCSSSize *haloSize = [[[[style objectForKey:@"text-halo-radius"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat haloRadius = nil == haloSize ? 0.0f : [haloSize value];
    BOOL hasHalo = haloRadius != 0.0f;
    
    UIColor *haloColour = [self colourWithColourSpecifierList:[style objectForKey:@"text-halo-color"] opacitySpecifierList:[style objectForKey:@"text-halo-opacity"]];
    UIColor *colour = [self colourWithColourSpecifierList:[style objectForKey:@"text-color"] opacitySpecifierList:[style objectForKey:@"text-opacity"]];
    
    OSPMapCSSSize *vOffsetSize = [[[[style objectForKey:@"text-offset"] specifiers] objectAtIndex:0] sizeValue];
    CGFloat offset = nil == vOffsetSize ? 0.0f : [vOffsetSize value];
    CGFloat scaledOffset = offset * scale;
    
    
//    CGContextSetLineWidth(ctx, haloRadius * 2.0f * scale);
//    CGContextSetFillColorWithColor(ctx, [colour CGColor]);
//    CGContextSetStrokeColorWithColor(ctx, [haloColour CGColor]);
    
//    CGFontRef gFont = CTFontCopyGraphicsFont(scaledFont, NULL);
//    CGContextSetFont(ctx, gFont);
//    CGContextSetFontSize(ctx, CTFontGetSize(scaledFont));
//    CFRelease(gFont);
	double lineWidth = 1;
    double wayOffset = [textWay textOffsetForTextWidth:lineWidth];
	
    if (wayOffset > 0)
    {
        BOOL backwards = [textWay positionOnWayWithOffset:wayOffset heightAboveWay:0.0 backwards:NO].x > [textWay positionOnWayWithOffset:wayOffset + lineWidth heightAboveWay:0.0 backwards:NO].x;
		[names addObject:text];
		
		int numGlyphs = text.length;
        for (int runNumber = 0; runNumber < numGlyphs; runNumber++)
        {
			int glyphOffset = [text characterAtIndex:runNumber];
            NSString *run = [NSString stringWithFormat:@"%c", glyphOffset];

            OSPCoordinate2D *glyphPositions = malloc((numGlyphs + 1) * sizeof(OSPCoordinate2D));
            CGFloat *glyphAngles = malloc(numGlyphs * sizeof(CGFloat));
            
            CGPoint currentGlyphOffset;
            for (int glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
            {
                currentGlyphOffset = CGPointMake(0, 0);
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
            
            if (hasHalo)
            {
//                CGContextSetTextDrawingMode(ctx, kCGTextStroke);
//                for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
//                {
//                    CGGlyph glyph = glyphs[glyphNumber];
//                    OSPCoordinate2D p = glyphPositions[glyphNumber];
//                    
//                    CGContextSetTextMatrix(ctx, CGAffineTransformConcat(CGAffineTransformMakeRotation(-glyphAngles[glyphNumber]), CGAffineTransformMakeScale(1.0, -1.0)));
//                    CGContextSetTextPosition(ctx, p.x, p.y);
//                    CGContextShowGlyphs(ctx, &glyph, 1);
//                }
            }
//            CGContextSetTextDrawingMode(ctx, kCGTextFill);
            for (CFIndex glyphNumber = 0; glyphNumber < numGlyphs; glyphNumber++)
            {
//                CGGlyph glyph = glyphs[glyphNumber];
//                OSPCoordinate2D p = glyphPositions[glyphNumber];
//                
//                CGContextSetTextMatrix(ctx, CGAffineTransformConcat(CGAffineTransformMakeRotation(-glyphAngles[glyphNumber]), CGAffineTransformMakeScale(1.0, -1.0)));
//                CGContextSetTextPosition(ctx, p.x, p.y);
//                CGContextShowGlyphs(ctx, &glyph, 1);
            }
            
            free(glyphPositions);
            free(glyphAngles);
        }
    }
}


- (UIImage *)imageWithSpecifierList:(OSPMapCSSSpecifierList *)spec
{
    if (nil != spec)
    {
        OSPMapCSSUrl *u = [[[spec specifiers] objectAtIndex:0] urlValue];
        NSURL *url = [u content];
        NSString *ext = [url pathExtension];
        NSString *resName = [[url lastPathComponent] stringByDeletingPathExtension];
        NSString *path = [[NSBundle mainBundle] pathForResource:resName ofType:ext];
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}

- (CGFloat *)createPathForWay:(OSPWay *)way length:(NSInteger*)length
{
	CGFloat *path;
	double NANODEG = 0.000001;
	int i = 0;
	
    for (int block = 0; block < way->cLength[0]; block++)
	{
		for (int node = 0; node < way->cLength[block+1]; node += 2)
		{
			float lat = way->cNodes[block][node+1] * NANODEG;
			float lon = way->cNodes[block][node] * NANODEG;
			
			OSPCoordinate2D nl = OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(lat, lon));			
			if (block == 0 && node == 0)
			{
				path = (CGFloat*)malloc(2*way->cLength[block+1]*sizeof(CGFloat));		
//				NSLog(@"%f, %f", nl.x, nl.y);
			}
			path[i] = (CGFloat)nl.x;
			path[i+1] = (CGFloat)nl.y;
			i += 2;
		}
	}
	
	*length = i/2;
	
    return path;
}

@end
