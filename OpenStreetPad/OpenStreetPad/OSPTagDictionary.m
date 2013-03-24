//
//  OSPTagDictionary.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 4/12/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPTagDictionary.h"

@implementation OSPTagDictionary
{
	NSMutableDictionary *keys;
	NSMutableDictionary *values;
	int keyCounter, valueCounter;
}

static OSPTagDictionary *_tags;

-(id)init
{
	self = [super init];
	_tags = self;
	if (self)
	{
		keys = [[NSMutableDictionary alloc] init];
		values = [[NSMutableDictionary alloc] init];
		keyCounter = valueCounter = 1;
	}
	return self;
}

+(id)tags
{
	@synchronized(self)
	{
		if (_tags == nil)
		{
			_tags = [[self alloc] init];
		}
	}
	return _tags;
}

-(int)getNumberWithDict:(NSMutableDictionary*)dict string:(NSString*)string andCounter:(int*)counter
{
	NSNumber *n = [dict objectForKey:string];
	if (n == nil)
	{
		n = [NSNumber numberWithInt:*counter];
		[dict setObject:n forKey:string];
		(*counter)++;
	}
	return [n intValue];	
}

-(int)getNumberForKey:(NSString*)string
{
	return [self getNumberWithDict:keys string:string andCounter:&keyCounter];
}

-(int)getNumberForValue:(NSString*)string
{
	return [self getNumberWithDict:values string:string andCounter:&valueCounter];
}

+(int)getNumberForKey:(NSString*)string
{
	return [[OSPTagDictionary tags] getNumberForKey:string];
}

+(int)getNumberForValue:(NSString*)string
{
	return [[OSPTagDictionary tags] getNumberForValue:string];
}

@end
