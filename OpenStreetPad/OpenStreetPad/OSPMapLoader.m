//
//  OSPMapLoader.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 4/28/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPMapLoader.h"
#import "OSPWay.h"

@interface OSPMapLoader()
{
	MapDatabase *mapDatabase;
	NSMutableArray *mapObjects;
	CGFloat _zoom;
	OSPMapArea mapArea;
	OSPCoordinateRect rect;
	BOOL fileOpened;
}

@end

@implementation OSPMapLoader

@synthesize mapObjects;
@synthesize mapArea;

- (id) initWithFile:(NSString*)path
{
	self = [super init];
	if (self)
	{
		mapDatabase = [[MapDatabase alloc] init];
		fileOpened = [mapDatabase openFile:path];
		mapObjects = [[NSMutableArray alloc] initWithCapacity:1000];
	}
	return self;
}

- (void) executeQueryForTileX:(int)x Y:(int)y Zoom:(int)zoom
{
	_zoom = zoom;
	
	rect = OSPRectForMapAreaInRect(mapArea, CGRectMake(0, 0, 256, 256));
	
	[mapObjects removeAllObjects];
	if (fileOpened == NO) return;
	Tile *tile = [[Tile alloc] init:x tileY:y zoomLevel:zoom];
 	[mapDatabase executeQuery:tile mapDatabaseCallback:self];
//	[tile release];
}

- (void) renderPointOfInterest:(char)layer latitude:(int)latitude longitude:(int)longitude tags:(NSMutableArray *)tags
{
	
}

- (void) renderWaterBackground
{
	
}

- (void) renderWay:(char)layer labelPosition:(float *)labelPosition tags:(NSMutableArray *)tags wayNodes:(float**)wayNodes
{
	
}

- (void) addNode:(int)nodeId latitude:(int)latitude longitude:(int)longitude tags:(NSMutableDictionary *)tags
{
	
}

- (void) addWay:(int)wayId nodes:(int **)nodes length:(int*)length labelPosition:(float *)labelPosition tags:(NSMutableDictionary *)tags layer:(int)layer
{
	@try {

//		double NANODEG = 0.000001;
//		BOOL rectContainsWay = NO;
//		
//		for (int block = 0; block < length[0]; block++)
//		{
//			for (int node = 0; node < length[block+1]; node += 2)
//			{
//				if (rectContainsWay) break;
//				float lat = nodes[block][node+1] * NANODEG;
//				float lon = nodes[block][node] * NANODEG;
//				OSPCoordinate2D coord = OSPCoordinate2DProjectLocation(CLLocationCoordinate2DMake(lat, lon));
////				NSLog(@"%f, %f", coord.x, coord.y);
////				NSLog(@"%f, %f, %f, %f", OSPCoordinateRectGetMinLatitude(rect), OSPCoordinateRectGetMaxLatitude(rect), OSPCoordinateRectGetMinLongitude(rect), OSPCoordinateRectGetMaxLongitude(rect));
//
//				if (coord.y > OSPCoordinateRectGetMinLatitude(rect) &&
//					coord.y < OSPCoordinateRectGetMaxLatitude(rect) &&
//					coord.x > OSPCoordinateRectGetMinLongitude(rect) &&
//					coord.x < OSPCoordinateRectGetMaxLongitude(rect) )
//				{
//					rectContainsWay = YES;
//				}
//			}
//		}
//
//		if (!rectContainsWay) 
//		{
//			int N = length[0];
//			for (int block = 0; block < N; block++)
//			{
//				free(nodes[block]);
//			}
//			free(nodes);
//			free(length);
//			return;
//		}
		
		BOOL forDelete = NO;
//		if ([tags objectForKey:@"tunnel"] != nil)
//		{
//			forDelete = YES;
//		}
		if (!forDelete)
		{
//			NSString *railway = [tags objectForKey:@"railway"];
//			if (railway != nil && ![railway isEqualToString:@"rail"])
//			{
//				forDelete = YES;
//			}
		}
		if (!forDelete && _zoom == 15)
		{
			if ([tags objectForKey:@"building"] != nil)
			{
				forDelete = YES;
			}
		}
		if (!forDelete && _zoom < 15)
		{
			NSString *highway = [tags objectForKey:@"highway"];
			if (
				[highway isEqualToString:@"footway"]
				|| [highway isEqualToString:@"pedestrian"]
				|| [highway isEqualToString:@"path"]
				|| [highway isEqualToString:@"residential"]
				|| [highway isEqualToString:@"service"]
				|| [highway isEqualToString:@"track"]
				|| [tags objectForKey:@"barrier"] != nil
				)
			{
				forDelete = YES;
			}
		}
		if (!forDelete && _zoom < 14)
		{
			
		}
		
		if (forDelete) 
		{
			int N = length[0];
			for (int block = 0; block < N; block++)
			{
				free(nodes[block]);
			}
			free(nodes);
			free(length);
			return;
		}
		
		OSPWay *way = [[OSPWay alloc] init];
		
		way->name = [tags objectForKey:@"name"];// retain];
		way->cNodes = nodes;
		way->cLength = length;
		way->labelPosition = labelPosition;
		//	way->isArea = [(NSString*)[tags objectForKey:@"area"] ospTruthValue];
		
		[way setIdentity:wayId];
		way.tags = tags;
		
		//	way->intTags = (int*)malloc(40*sizeof(int));
		//	for (int i = 0; i < 40; i++)
		//	{
		//		way->intTags[i] = 0;
		//	}
		//	for (NSString *key in [tags allKeys])
		//	{
		//		if ([key isEqualToString:@"name"]) continue;
		//		way->intTags[[OSPTagDictionary getNumberForKey:key]] = [OSPTagDictionary getNumberForValue:[tags objectForKey:key]];
		//	}
		
		//	NSMutableDictionary *newTags = [NSMutableDictionary dictionaryWithCapacity:tags.count];
		//	for (NSString *key in [tags allKeys])
		//	{
		//		[newTags setObject:[intTagsDict getNumberForValue:[tags objectForKey:key]] forKey:[intTagsDict getNumberForKey:key]];
		//	}
		//	[way setTags:newTags];
		[mapObjects addObject:way];
//		[way release];
	}
	@catch (NSException *e) {
		NSLog(@"Exception while adding ways");
	}
}

@end
