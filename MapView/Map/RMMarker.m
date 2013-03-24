//
//  RMMarker.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMMarker.h"

#import "RMPixel.h"

@implementation RMMarker

@synthesize projectedLocation;
@synthesize enableDragging;
@synthesize enableRotation;
@synthesize data;
@synthesize label;
@synthesize textForegroundColor;
@synthesize textBackgroundColor;

#define defaultMarkerAnchorPoint CGPointMake(0.5, 0.5)

+ (UIFont *)defaultFont
{
	return [UIFont systemFontOfSize:15];
}

// init
- (id)init
{
    if (self = [super init]) {
        label = nil;
        textForegroundColor = [UIColor blackColor];
        textBackgroundColor = [UIColor clearColor];
		enableDragging = YES;
		enableRotation = YES;
    }
    return self;
}

- (id) initWithUIImage: (UIImage*) image
{
	return [self initWithUIImage:image anchorPoint: defaultMarkerAnchorPoint];
}

- (id) initWithUIImage: (UIImage*) image anchorPoint: (CGPoint) _anchorPoint
{
	if (![self init])
		return nil;
	
	self.contents = (id)[image CGImage];
	self.bounds = CGRectMake(0,0,image.size.width,image.size.height);
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
	self.label = nil;
	
	return self;
}

- (void) replaceUIImage: (UIImage*) image
{
	[self replaceUIImage:image anchorPoint:defaultMarkerAnchorPoint];
}

- (void) replaceUIImage: (UIImage*) image
			anchorPoint: (CGPoint) _anchorPoint
{
	self.contents = (id)[image CGImage];
	self.bounds = CGRectMake(0,0,image.size.width,image.size.height);
	self.anchorPoint = _anchorPoint;
	
	self.masksToBounds = NO;
}

- (void) setLabel:(UIView*)aView
{
	if (label == aView) {
		return;
	}

	if (label != nil)
	{
		[[label layer] removeFromSuperlayer];
		[label release];
		label = nil;
	}
	
	if (aView != nil)
	{
		label = [aView retain];
		[self addSublayer:[label layer]];
	}
}

- (void) changeLabelUsingText: (NSString*)text
{
	CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:[RMMarker defaultFont]].width / 2, 4);
/// \bug hardcoded font name
	[self changeLabelUsingText:text position:position font:[RMMarker defaultFont] foregroundColor:[self textForegroundColor] backgroundColor:[self textBackgroundColor]];
}

- (void) changeLabelUsingText: (NSString*)text position:(CGPoint)position
{
	[self changeLabelUsingText:text position:position font:[RMMarker defaultFont] foregroundColor:[self textForegroundColor] backgroundColor:[self textBackgroundColor]];
}

- (void) changeLabelUsingText: (NSString*)text font:(UIFont*)font foregroundColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor
{
	CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:font].width / 2, 4);
	[self setTextForegroundColor:textColor];
	[self setTextBackgroundColor:backgroundColor];
	[self changeLabelUsingText:text  position:position font:font foregroundColor:textColor backgroundColor:backgroundColor];
}

- (void) changeLabelUsingText: (NSString*)text position:(CGPoint)position font:(UIFont*)font foregroundColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor
{
	CGSize textSize = [text sizeWithFont:font];
	CGRect frame = CGRectMake(position.x,
							  position.y,
							  textSize.width+4,
							  textSize.height+4);
	
	UILabel *aLabel = [[UILabel alloc] initWithFrame:frame];
	[self setTextForegroundColor:textColor];
	[self setTextBackgroundColor:backgroundColor];
	[aLabel setNumberOfLines:0];
	[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[aLabel setBackgroundColor:backgroundColor];
	[aLabel setTextColor:textColor];
	[aLabel setFont:font];
	[aLabel setTextAlignment:UITextAlignmentCenter];
	[aLabel setText:text];
	
	[self setLabel:aLabel];
	[aLabel release];
}

- (void) toggleLabel
{
	if (self.label == nil) {
		return;
	}
	
	if ([self.label isHidden]) {
		[self showLabel];
	} else {
		[self hideLabel];
	}
}

- (void) showLabel
{
	if ([self.label isHidden]) {
		// Using addSublayer will animate showing the label, whereas setHidden is not animated
		[self addSublayer:[self.label layer]];
		[self.label setHidden:NO];
	}
}

- (void) hideLabel
{
	if (![self.label isHidden]) {
		// Using removeFromSuperlayer will animate hiding the label, whereas setHidden is not animated
		[[self.label layer] removeFromSuperlayer];
		[self.label setHidden:YES];
	}
}

#define TITLE_FONT_SIZE  17
#define SUBTITLE_FONT_SIZE  12

#define CALLOUT_LEFT_IMAGE [[UIImage imageNamed:@"callout_left.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:0]
#define CALLOUT_CENTER_IMAGE [UIImage imageNamed:@"callout_center.png"]
#define CALLOUT_RIGHT_IMAGE [[UIImage imageNamed:@"callout_right.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]

//
//Стас: добавил BOOL disclosure, чтобы можно было выбирать нужна ли нам кнопка в callout или нет.
//

- (void)showBallonWithTitle:(NSString *)title subtitle:(NSString *)subtitle disclosure:(BOOL)disclosure
{
    float maxWidth = self.superlayer.bounds.size.width - 80;
    CGSize size = [title sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:TITLE_FONT_SIZE]];
    size.width = MIN(maxWidth, size.width);
    float width = (disclosure) ? size.width + 50 : size.width + 30;
    NSLog(@"width %f", width);
    float leftWidth = width / 2;
    float rightWidth = width / 2;
    
    if (leftWidth > self.position.x - 10) {
        leftWidth = MAX(20, self.position.x - 10);
        rightWidth = width - leftWidth;
    } else if (rightWidth > self.superlayer.bounds.size.width - self.position.x - 10) {
        rightWidth = MAX(20, self.superlayer.bounds.size.width - self.position.x - 10);
        leftWidth = width - rightWidth;
    }
    
    NSLog(@"leftWidth %f", leftWidth);
    NSLog(@"rightWidth %f", rightWidth);

    self.label = [[[UIView alloc] initWithFrame:CGRectMake(-leftWidth + 10, -60, width, 70)] autorelease];
    
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;
    
    UIImageView *calloutLeft = [[UIImageView alloc] initWithFrame:CGRectMake(-15, 0, leftWidth , 70)];
    calloutLeft.image = CALLOUT_LEFT_IMAGE;
    [label addSubview:calloutLeft];
    [calloutLeft release];
    
    UIImageView *calloutCenter = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(calloutLeft.frame) , 0, 30, 70)];
    calloutCenter.image = CALLOUT_CENTER_IMAGE;
    [label addSubview:calloutCenter];
    [calloutCenter release];
    
    UIImageView *calloutRight = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(calloutCenter.frame)  , 0, rightWidth , 70)];
    calloutRight.image = CALLOUT_RIGHT_IMAGE;
    [label addSubview:calloutRight];
    [calloutRight release];
    
    UILabel *calloutLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, size.width, 22)];
    calloutLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:TITLE_FONT_SIZE];
    calloutLabel.text = title;
    calloutLabel.textColor = [UIColor whiteColor];
    calloutLabel.backgroundColor = [UIColor clearColor];
    calloutLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    calloutLabel.shadowOffset = CGSizeMake(0, -1);
    
    
    if (![subtitle isEqualToString:@""]) {
        calloutLabel.frame = CGRectMake(15, 6, size.width, 22);
        
        UILabel *calloutSublabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 27, size.width, 15)];
        calloutSublabel.font = [UIFont systemFontOfSize:SUBTITLE_FONT_SIZE];
        calloutSublabel.text = subtitle;
        calloutSublabel.textColor = [UIColor whiteColor];
        calloutSublabel.backgroundColor = [UIColor clearColor];
        calloutSublabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        calloutSublabel.shadowOffset = CGSizeMake(0, -1);
        [label addSubview:calloutSublabel];
        [calloutSublabel release];
    }
    [label addSubview:calloutLabel];
    [calloutLabel release];
    
    if (disclosure) 
    {
        UIButton *button = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
        button.frame = CGRectMake(CGRectGetMaxX(calloutLabel.frame) , 9, 34, 34);
        button.userInteractionEnabled = NO;
        [label addSubview:button];
    }
}

- (void) dealloc 
{
    self.data = nil;
    //TODO Тимур. если обнулять label имеет свойство падать с адресного контролла при добавление места. потом проверить удаляется память или нет
   // self.label = nil;
    self.textForegroundColor = nil;
    self.textBackgroundColor = nil;
	[super dealloc];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
	if(enableDragging){
		self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, center);
	}
}

- (void)moveBy: (CGSize) delta
{
	if(enableDragging){
		[super moveBy:delta];
	}
}

@end
