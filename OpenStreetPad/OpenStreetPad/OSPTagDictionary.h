//
//  OSPTagDictionary.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 4/12/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSPTagDictionary : NSObject

+(int)getNumberForKey:(NSString*)string;
+(int)getNumberForValue:(NSString*)string;

@end
