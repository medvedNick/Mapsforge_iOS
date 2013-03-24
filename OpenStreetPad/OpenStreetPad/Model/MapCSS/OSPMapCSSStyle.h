//
//  Style.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 31/10/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreParse.h"
#import "OSPMapCSSSpecifierList.h"

@class OSPMapCSSRule;

@interface OSPMapCSSStyle : NSObject <CPParseResult>

@property (nonatomic, readwrite, assign) BOOL containsRule;
@property (nonatomic, readwrite, retain) OSPMapCSSRule *rule;
@property (nonatomic, readwrite, assign, getter = isExit) BOOL exit;
@property (nonatomic, readwrite, retain/*copy*/) NSString *key;
@property (nonatomic, readwrite, retain) OSPMapCSSSpecifierList *specifiers;

@end
