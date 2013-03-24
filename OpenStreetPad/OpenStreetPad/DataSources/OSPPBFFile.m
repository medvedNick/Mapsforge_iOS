//
//  OSPPBFFile.m
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/12/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import "OSPPBFFile.h"
#import "OSPMap.h"

#import "zlib.h"

#include <libkern/OSByteOrder.h>

#define NANO_DEGREE .000000001

@interface OSPPBFFile()

-(void)__loadObjectsInBounds:(OSPCoordinateRect)bounds withOutset:(double)outsetSize fromFile:(NSString*)resource;


-(void) processDenseNodes:(PrimitiveGroup*)group stringTable:(StringTable*)stable
			latOffset:(double)latOffset
			lonOffset:(double)lonOffset
			granularity:(double)granularity;
	
-(void) processWays:(PrimitiveGroup*)group stringTable:(StringTable*)stable
			latOffset:(double)latOffset
			lonOffset:(double)lonOffset
			granularity:(double)granularity;

@end


@implementation OSPPBFFile

@synthesize cache;
@synthesize path;

+(id) pbfFileWithFile:(NSString *)path
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
    }
    
    return self;
}

- (NSSet *)objectsInBounds:(OSPCoordinateRect)bounds
{
    return [[self cache] objectsInBounds:bounds];
}

- (NSSet *)allObjects
{
    return [[self cache] allObjects];
}

-(void) resetObjects
{
	
}

- (void) loadObjectsFromFile:(NSString *)resource
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
				   {
					   [self __loadObjectsInBounds:OSPCoordinateRectMake(0, 0, 0, 0) withOutset:0 fromFile:resource];
					   [[self delegate] dataSource:self didLoadObjectsInArea:OSPCoordinateRectMake(0.0, 0.0, 1.0, 1.0)];
				   });
}



- (void)loadObjectsInBounds:(OSPCoordinateRect)bounds withOutset:(double)outsetSize
{
	[self loadObjectsFromFile:path];
}

- (void)__loadObjectsInBounds:(OSPCoordinateRect)bounds withOutset:(double)outsetSize fromFile:(NSString*)resource
{
	NSData *data = [NSData dataWithContentsOfFile:resource];
	[self loadObjectsFromData:data];
}

-(void) loadObjectsFromData:(NSData*)data
{
	@try {
		// reading blocks of data
		while (data.length > 0)
		{
			int len;
			[data getBytes:&len length:sizeof(int)/*is equal to 4*/];
			len = OSSwapInt32(len);
			
			NSRange headerRange = NSMakeRange(4, len);
			BlobHeader *blobHeader = [BlobHeader parseFromData:[data subdataWithRange:headerRange]];
			
			NSRange blobRange = NSMakeRange(4+len, blobHeader.datasize);
			Blob *blob = [Blob parseFromData:[data subdataWithRange:blobRange]];
			
			NSData *blobData;
			if(blob.hasZlibData)
			{
				uLongf destLen = blob.rawSize;
				Bytef *dest = malloc(destLen*sizeof(Bytef));
				// uncompressing data with zlib
				int error = uncompress(dest, &destLen, blob.zlibData.bytes, blob.zlibData.length);
				switch (error) {
					case Z_MEM_ERROR:
						NSLog(@"Memory somewhere went wrong");
						break;
					case Z_BUF_ERROR:
						NSLog(@"Buffer somewhere went wrong");
						break;
					case Z_DATA_ERROR:
						NSLog(@"Data somewhere went wrong");
						break;
					default:
						break;
				}
				blobData = [NSData dataWithBytes:dest length:destLen];
			}
			else
			{
				blobData = blob.data;
			}
			
			if ([blobHeader.type isEqualToString:@"OSMHeader"])
			{
				// this header block has bounding box of file, it does not need for drawing
//				HeaderBlock *hb = [HeaderBlock parseFromData:blobData];
			}
			else if ([blobHeader.type isEqualToString:@"OSMData"])
			{
				PrimitiveBlock *pb = [PrimitiveBlock parseFromData:blobData];
				StringTable *stable = pb.stringtable;
				
				double latOffset = NANO_DEGREE * pb.latOffset;
				double lonOffset = NANO_DEGREE * pb.lonOffset;
				double granularity = NANO_DEGREE * pb.granularity;
				
				for (PrimitiveGroup *group in pb.primitivegroupList)
				{
					if (group.hasDense)
					{
						[self processDenseNodes:group stringTable:stable latOffset:latOffset lonOffset:lonOffset granularity:granularity];
					}
					if (group.waysList.count != 0)
					{
						[self processWays:group stringTable:stable latOffset:latOffset lonOffset:lonOffset granularity:granularity];
					}
				}
			}
			
			int blockSize = 4+len+blobHeader.datasize;
			data = [data subdataWithRange:NSMakeRange(blockSize, data.length-blockSize)];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Exception in [OSPPBFFile loadObjectsFromData: %@, %@", exception.name, exception.reason);
	}
}

-(void) processDenseNodes:(PrimitiveGroup*)group stringTable:(StringTable*)stable
				latOffset:(double)latOffset
				lonOffset:(double)lonOffset
			  granularity:(double)granularity
{
	unsigned l = 0;
	long int deltaid = 0;
	long int deltalat = 0;
	long int deltalon = 0;
	
//	Timestamp, userId and others are not needed for drawing, so we can skip them
	
//	unsigned long int deltatimestamp = 0;
//	unsigned long int deltachangeset = 0;
//	long int deltauid = 0;
//	unsigned long int deltauser_sid = 0;
	
	double lat, lon;
	
	DenseNodes *dense = group.dense;
	for (int i = 0; i < dense.idList.count; i++)
	{
		// lat and lon are coded with delta encoding
		deltaid += [dense idAtIndex:i];
		deltalat += [dense latAtIndex:i];
		deltalon += [dense lonAtIndex:i];

		NSMutableDictionary *tags = [NSMutableDictionary dictionary];
		
		if (l < dense.keysValsList.count)
		{
			while ([dense keysValsAtIndex:l] != 0 && l < dense.keysValsList.count)
			{
				NSData *objData = [stable sAtIndex:[dense keysValsAtIndex:l+1]];
				NSData *keyData = [stable sAtIndex:[dense keysValsAtIndex:l]];
				
				NSString *obj = [[NSString alloc] initWithData:objData encoding:NSUTF8StringEncoding];
				NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
				
				[tags setValue:obj forKey:key];
				
//				[obj release];
//				[key release];

				l += 2;
			}
			l++;
		}
		
		lat = latOffset + (deltalat * granularity);
		lon = lonOffset + (deltalon * granularity);
	
		OSPNode *node = [[OSPNode alloc] init];
		[node setLocation:CLLocationCoordinate2DMake(lat, lon)];
		[node setIdentity:deltaid];
		[node setMap:(OSPMap*)self.cache];
		[node setVisible:YES];
		[node setTags:tags];

		[self.cache addObject:node];
	}
}

-(void) processWays:(PrimitiveGroup*)group stringTable:(StringTable*)stable
				latOffset:(double)latOffset
				lonOffset:(double)lonOffset
			  granularity:(double)granularity
{
	for (int i = 0; i < group.waysList.count; i++)
	{
		Way *way = [group waysAtIndex:i];
		OSPWay *ospWay = [[OSPWay alloc] init];
				
		long int deltaref = 0;
		
		// references for nodes are coded with delta encoding
		for (int ref = 0; ref < way.refsList.count; ref++)
		{
			deltaref += [way refsAtIndex:ref];
			[ospWay addNodeWithId:deltaref];
		}
		
		NSMutableDictionary *tags = [NSMutableDictionary dictionary];
		
		for (int keyId = 0; keyId < way.keysList.count; keyId++)
		{
			NSData *objData = [stable sAtIndex:[way valsAtIndex:keyId]];
			NSData *keyData = [stable sAtIndex:[way keysAtIndex:keyId]];
			
			NSString *obj = [[NSString alloc] initWithData:objData encoding:NSUTF8StringEncoding];
			NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];			
			
			[tags setValue:obj forKey:key];
			
//			[obj release];
//			[key release];
		}
		
		[ospWay setTags:tags];
		[ospWay setVisible:YES];
		[ospWay setMap:(OSPMap*)self.cache];
		[ospWay setIdentity:way.id];

		[self.cache addObject:ospWay];
	}
}

@end
