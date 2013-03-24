//
//  EvalSpecifier.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 31/10/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import "OSPMapCSSSpecifier.h"

#import "OSPMapCSSEval.h"

@interface OSPMapCSSEvalSpecifier : OSPMapCSSSpecifier

@property (nonatomic, readwrite, retain) OSPMapCSSEval *eval;

@end
