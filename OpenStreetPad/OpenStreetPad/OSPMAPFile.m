//
//  OSPMAPFile.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/27/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPMAPFile.h"
#import "OSPMap.h"
#import "OSPNode.h"
#import "OSPWay.h"

@implementation OSPMAPFile
{
	MapDatabase *mapDatabase;
}

@synthesize cache;
@synthesize path;

+(id) mapFileWithFile:(NSString *)path
{
	return [[self alloc] initWithFile:path];
}

-(id) initWithFile:(NSString*)initPath
{
    self = [super init];
    
    if (nil != self)
    {
        [self setPath:initPath];
        [self setCache:[[OSPMap alloc] init]];
		mapDatabase = [[MapDatabase alloc] init];
		[mapDatabase openFile:initPath];
    }
    
    return self;
}

-(void) loadObjectsForTileX:(int)x Y:(int)y zoom:(int)zoom
{
	Tile *tile = [[Tile alloc] init:x tileY:y zoomLevel:zoom];
	[mapDatabase executeQuery:tile mapDatabaseCallback:self];
}

- (void) addNode:(int)nodeId latitude:(int)latitude longitude:(int)longitude tags:(NSMutableDictionary *)tags
{
	static int nodes = 0;
	nodes++;
	if (nodes % 1000 == 0) NSLog(@"nodes: %d", nodes);
	OSPNode *node = [[OSPNode alloc] init];

	double NANODEG = 0.000001;
	[node setLocation:CLLocationCoordinate2DMake(latitude*NANODEG, longitude*NANODEG)];
	[node setIdentity:nodeId];
	[node setTags:tags];
	[node setMap:(OSPMap*)self.cache];
	[node setVisible:YES];
	
	[self.cache addObject:node];
}

- (void) addWay:(int)wayId nodes:(NSArray *)nodes tags:(NSMutableDictionary *)tags
{
	static int nodeId = 6666666;
	int count = 0;
	for (NSArray *waySegment in nodes)
	{
		count += waySegment.count;
	}
	
	OSPWay *way = [[OSPWay alloc] init];
//	NSMutableArray *nodeIds = [NSMutableArray arrayWithCapacity:count];
	
	for (NSArray *waySegment in nodes)
	{
		for (int i = 0; i < waySegment.count; i+=2)
		{
			int lat = [(NSNumber*)[waySegment objectAtIndex:i+1] longValue];
			int lon = [(NSNumber*)[waySegment objectAtIndex:i] longValue];
//			NSLog(@"%d, %d", lat, lon);
			[self addNode:nodeId latitude:lat longitude:lon tags:[NSDictionary dictionary]];
//			[nodeIds addObject:[NSNumber numberWithLong:nodeId]];
			[way addNodeWithId:nodeId];
			nodeId++;
		}
	}
//	NSLog(@"Way length: %d", way.nodes.count);
	[way setIdentity:wayId];
	[way setTags:tags];
	[way setMap:(OSPMap*)self.cache];
	[way setVisible:YES];
	
	[self.cache addObject:way];
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

- (NSSet *)objectsInBounds:(OSPCoordinateRect)bounds
{
    return [[self cache] objectsInBounds:bounds];
}

- (NSSet *)allObjects
{
    return [[self cache] allObjects];
}

@end

