//
//  RMOSPTileSourceManager.m
//  MapView
//
//  Created by Nikita Medvedev on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RMOSPTileSourceManager.h"

@implementation RMOSPTileSourceManager
{
	NSMutableDictionary *index;
	NSMutableArray *cache;
}

-(id) initWithResource:(NSString*)resource
{
	self = [super init];
	if (self)
	{
		//		NSData *data = [[NSMutableData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@""]];
		//		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		//		index = [unarchiver decodeObjectForKey: @"tiles"];
		//		[unarchiver finishDecoding];
		//		[unarchiver release];
		//		[data release];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		NSData *data = [NSMutableData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@""]];

		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		index = [unarchiver decodeObjectForKey: @"tile"];
		[unarchiver finishDecoding];

		cache = [[NSMutableArray alloc] init];
	}
	return self;
}

-(NSData*) dataForTile:(RMTile)tile
{
//	if (tile.zoom < 16) return nil;
	int BREAK = 8;
	uint64_t _x = tile.x, _y = tile.y, _z = tile.zoom;
//	NSLog(@"%llu, %llu, %llu", _x, _y, _z);
	_x /= BREAK;
	_y /= BREAK;
	BOOL found = NO;
	uint64_t zoom, x, y, key;
	
	while (!found)
	{
		NSLog(@"%llu, %llu, %llu", _x, _y, _z);
		zoom = (uint64_t) _z & 0xFFLL; // 8bits, 256 levels
		x = (uint64_t) _x  & 0xFFFFFFFLL;  // 28 bits
		y = (uint64_t) _y  & 0xFFFFFFFLL;  // 28 bits
		
		key = (zoom << 56) | (x << 28) | (y << 0);
//		NSLog(@"%llu", key);
		NSString *k = [NSString stringWithFormat:@"%llu", key];
//		NSString *qwerty =  [index objectForKey:k];
//		NSLog(@"%@", qwerty);
		if ([index objectForKey:k] != nil)
		{
			found = YES;
		}
		else
		{
			_x *= 2;
			_y *= 2;
			_z++;
			
			if (_z > 20) return nil;
		}
	}
		
	for (NSNumber *cachedKey in cache)
	{
		uint64_t value = [cachedKey longLongValue];
		if (value == key) return nil;
	}
	[cache addObject:[NSNumber numberWithLongLong:key]];
	
	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZOOM" ofType:@""] options:NSMappedRead error:nil];
	
	NSString *keyStr = [NSString stringWithFormat:@"%llu", key];
	NSString *value = [index objectForKey:keyStr];
	NSLog(@"%@", value);
	NSArray *strings = [value componentsSeparatedByString:@":::"];
	
	NSInteger loc = [(NSString*)[strings objectAtIndex:0] intValue];
	NSInteger len = [(NSString*)[strings objectAtIndex:1] intValue];

	return [data subdataWithRange:NSMakeRange(loc, len)];
}

@end
