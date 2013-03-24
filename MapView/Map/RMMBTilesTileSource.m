//
//  RMMBTilesTileSource.m
//
//  Created by Justin R. Miller on 6/18/10.
//  Copyright 2010, Code Sorcery Workshop, LLC and Development Seed, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the names of Code Sorcery Workshop, LLC or Development Seed,
//        Inc., nor the names of its contributors may be used to endorse or
//        promote products derived from this software without specific prior
//        written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "RMMBTilesTileSource.h"
#import "RMTileImage.h"
#import "RMProjection.h"
#import "RMFractalTileProjection.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#pragma mark -

@implementation RMMBTilesTileSource

- (id)initWithTileSetURL:(NSURL *)tileSetURL
{
	if ( ! [super init])
		return nil;
	
	tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[self projection] 
                                                          tileSideLength:kMBTilesDefaultTileSize 
                                                                 maxZoom:kMBTilesDefaultMaxTileZoom 
                                                                 minZoom:kMBTilesDefaultMinTileZoom];
	
    db = [[FMDatabase databaseWithPath:[tileSetURL relativePath]] retain];
    
    if ( ! [db open])
        return nil;
    
	return self;
}

- (void)dealloc
{
	[tileProjection release];
    
    [db close];
    [db release];
    
	[super dealloc];
}

- (int)tileSideLength
{
	return tileProjection.tileSideLength;
}

- (void)setTileSideLength:(NSUInteger)aTileSideLength
{
	[tileProjection setTileSideLength:aTileSideLength];
}

- (RMTileImage *)tileImage:(RMTile)tile
{
    NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);

    NSInteger k = 0;
    
    NSData *data = nil;
    
    while (tile.zoom - k > 0) {
    
        NSInteger k2 = pow(2, k);
        
        NSInteger zoom = tile.zoom - k;
        NSInteger x    = floorf(tile.x / k2);
        NSInteger y    = floorf(tile.y / k2);

        data = [db dataForQuery:@"select tile_data from tiles where zoom_level = ? and tile_column = ? and tile_row = ?", 
                [NSNumber numberWithFloat:zoom], 
                [NSNumber numberWithFloat:x], 
                [NSNumber numberWithFloat:pow(2, zoom) - y - 1]];
    
        if ([db hadError])
            return [RMTileImage dummyTile:tile];
        
        if (!data) {
            k++;
        } else {
            if (k == 0)
                break;
            
            UIImage *image = [UIImage imageWithData:data];
            
            CGFloat width = image.size.width / k2;
            CGFloat height = image.size.height / k2;
            
            CGFloat rx = (tile.x - x * k2) * width;
            CGFloat ry = (tile.y - y * k2) * height;
            
            CGRect cropRect = CGRectMake(rx, ry, width, height);
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
            UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
            data = UIImagePNGRepresentation(cropImage);
            
            CGImageRelease(imageRef);
            
            break;
        }
    }
    
    RMTileImage *image;
    
    if (!data)
        image = [RMTileImage dummyTile:tile];
    else
        image = [RMTileImage imageForTile:tile withData:data];
    
    return image;
}

- (NSString *)tileURL:(RMTile)tile
{
    return nil;
}

- (NSString *)tileFile:(RMTile)tile
{
    return nil;
}

- (NSString *)tilePath
{
    return nil;
}

- (id <RMMercatorToTileProjection>)mercatorToTileProjection
{
	return [[tileProjection retain] autorelease];
}

- (RMProjection *)projection
{
	return [RMProjection googleProjection];
}

- (float)minZoom
{
    FMResultSet *results = [db executeQuery:@"select min(zoom_level) from tiles"];
    
    if ([db hadError] || ![results next])
        return kMBTilesDefaultMinTileZoom;
    
    double minZoom = [results doubleForColumnIndex:0];
    
    [results close];
    
    return (float)minZoom;
}

- (float)maxZoom
{
    FMResultSet *results = [db executeQuery:@"select max(zoom_level) from tiles"];
    
    if ([db hadError] || ![results next])
        return kMBTilesDefaultMaxTileZoom;
    
    double maxZoom = [results doubleForColumnIndex:0];
    
    [results close];
    
    return (float)maxZoom;
}

- (void)setMinZoom:(NSUInteger)aMinZoom
{
    [tileProjection setMinZoom:aMinZoom];
}

- (void)setMaxZoom:(NSUInteger)aMaxZoom
{
    [tileProjection setMaxZoom:aMaxZoom];
}

- (RMSphericalTrapezium)latitudeLongitudeBoundingBox
{
    return kMBTilesDefaultLatLonBoundingBox;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"*** didReceiveMemoryWarning in %@", [self class]);
}

- (NSString *)uniqueTilecacheKey
{
    return [NSString stringWithFormat:@"MBTiles%@", [[db databasePath] lastPathComponent]];
}

- (NSString *)shortName
{
    FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'name'"];
    
    if ([db hadError])
        return @"Unknown MBTiles";
    
    [results next];
    
    NSString *shortName = [results stringForColumnIndex:0];
    
    [results close];
    
    return shortName;
}

- (NSString *)longDescription
{
    FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'description'"];
    
    if ([db hadError])
        return @"Unknown MBTiles description";
    
    [results next];
    
    NSString *description = [results stringForColumnIndex:0];
    
    [results close];
    
    return [NSString stringWithFormat:@"%@ - %@", [self shortName], description];
}

- (NSString *)shortAttribution
{
    FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'attribution'"];
    
    if ([db hadError])
        return @"Unknown MBTiles attribution";
    
    [results next];
    
    NSString *attribution = [results stringForColumnIndex:0];
    
    [results close];
    
    return attribution;
}

- (NSString *)constraints
{
    return nil;
    
    FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'bounds'"];
    
    if ([db hadError])
        return nil;
    
    [results next];
    
    NSString *attribution = [results stringForColumnIndex:0];
    
    [results close];
    
    return attribution;
}

- (NSString *)longAttribution
{
    return [NSString stringWithFormat:@"%@ - %@", [self shortName], [self shortAttribution]];
}

- (void)removeAllCachedImages
{
    NSLog(@"*** removeAllCachedImages in %@", [self class]);
}

@end