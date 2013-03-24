//
//  Subselector.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 02/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreParse.h"

#import "OSPMapCSSClass.h"
#import "OSPMapCSSObject.h"

#import "OSPAPIObject.h"

@interface OSPMapCSSSubselector : NSObject <CPParseResult>

@property (nonatomic, readwrite, assign) OSPMapCSSObjectType objectType;
@property (nonatomic, readwrite, assign, getter=isConstrainedToZoomRange) BOOL constrainedToZoomRange;
@property (nonatomic, readwrite, assign) float minimumZoom;
@property (nonatomic, readwrite, assign) float maximumZoom;
@property (nonatomic, readwrite, retain/*copy*/) NSArray *tests;
@property (nonatomic, readwrite, strong) OSPMapCSSClass *requiredClass;

- (BOOL)matchesObject:(OSPAPIObject *)object atZoom:(float)zoom;
- (BOOL)zoomIsInRange:(float)zoom;

@end
