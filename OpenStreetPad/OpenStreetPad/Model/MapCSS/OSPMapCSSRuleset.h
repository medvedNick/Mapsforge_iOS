//
//  Ruleset.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 02/11/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPAPIObject.h"

//#import "CoreParse.h"

@protocol CPParseResult;

@interface OSPMapCSSRuleset : NSObject <CPParseResult>

@property (nonatomic, readwrite, retain/*copy*/) NSArray *rules;

- (void)loadImportsRelativeToURL:(NSURL *)baseURL;

- (NSDictionary *)applyToObject:(OSPAPIObject *)object atZoom:(float)zoom;
- (NSDictionary *)styleForCanvasAtZoom:(float)zoom;

@end
