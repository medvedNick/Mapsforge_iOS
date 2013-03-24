//
//  OSPMapCSSTagSpec.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 06/02/2012.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreParse.h"

@interface OSPMapCSSTagSpec : NSObject <CPParseResult>

@property (nonatomic, readwrite, retain/*copy*/) NSString *tag;

@end
