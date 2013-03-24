//
//  Rule.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 02/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPAPIObject.h"

#import "CoreParse.h"

@interface OSPMapCSSRule : NSObject <CPParseResult>

@property (nonatomic, readwrite, retain/*copy*/) NSArray *selectors;
@property (nonatomic, readwrite, retain/*copy*/) NSArray *declarations;

- (NSDictionary *)applyToObject:(OSPAPIObject *)object atZoom:(float)zoom stop:(BOOL *)stop;

@end
