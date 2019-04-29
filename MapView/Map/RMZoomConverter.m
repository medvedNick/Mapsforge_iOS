//
//  RMZoomConverter.m
//  LayeredMap
//
//  Created by Tomáš Kohout on 03.03.13.
//
//

#import "RMZoomConverter.h"
#import "RMTile.h"
#import <CoreLocation/CoreLocation.h>

#import "../../fmdb/FMDatabase.h"

@implementation RMZoomConverter
RMTile baseTile;
int zoomSteps;

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

int minZoom;

- initWithBaseTile: (RMTile) aBaseTile zoomSteps: (int) aZoomSteps{
    self = [super init];
    
    if (self){
        baseTile.x = aBaseTile.x;
        baseTile.y = aBaseTile.y;
        baseTile.zoom  = aBaseTile.zoom;
        minZoom = aZoomSteps;
        zoomSteps = aZoomSteps;
    }
    return self;
}


-(id)initWithBaseCoord:(CLLocationCoordinate2D)aBaseCoord minZoom: (int) aMinZoom zoomSteps: (int) aZoomSteps{
    self = [super init];
    
    if (self){
        
        minZoom = [self convertZoom: aMinZoom];
        
        RMTileDec baseTileDec = [self coordinateToTile:aBaseCoord zoom:minZoom];
        baseTile.x = [baseTileDec.x intValue];
        baseTile.y = [baseTileDec.y intValue];
        baseTile.zoom = baseTileDec.zoom ;
        
        zoomSteps = aZoomSteps;
    }
    return self;
}

-(int)maxZoom{
    return [self convertZoom:21];
}

- (double) convertZoom: (double) zoom{
    return zoom - zoomSteps;
}

- (int)minZoom{
    return minZoom;
}

#pragma mark Tile conversion

//Loosing precision when zooming down!!!
- (RMTile) convertTile: (RMTile) tile toZoom: (int) zoom{
    RMTile newTile;
    
    double multiplier =  (double)pow(2, tile.zoom - zoom);
    
    newTile.x = tile.x / multiplier;
    newTile.y = tile.y / multiplier;
    newTile.zoom = zoom;
    
    return newTile;
}

- (RMTile) reverseConvertTile: (RMTile) tile{
    RMTile converted;
    
    RMTile baseTileToTileZoom = [self convertTile:baseTile toZoom: tile.zoom];
    
    RMTile baseTileToSmallerZoom = [self convertTile:baseTile toZoom: tile.zoom - zoomSteps];
    
    converted.x = baseTileToSmallerZoom.x + (tile.x - baseTileToTileZoom.x);
    converted.y = baseTileToSmallerZoom.y + (tile.y - baseTileToTileZoom.y);
    converted.zoom = tile.zoom - zoomSteps;
    
    return converted;
}

- (RMTile) convertTile: (RMTile) tile{
    RMTile converted;
    
    RMTile baseTileToTileZoom = [self convertTile:baseTile toZoom: tile.zoom];
    
    RMTile baseTileToBiggerZoom = [self convertTile:baseTile toZoom: tile.zoom + zoomSteps];
    
    converted.x = baseTileToBiggerZoom.x + (tile.x - baseTileToTileZoom.x);
    converted.y = baseTileToBiggerZoom.y + (tile.y - baseTileToTileZoom.y);
    converted.zoom = tile.zoom + zoomSteps;
    
    return converted;
}

#pragma mark Coordinate conversion

- (RMTileDec) coordinateToTile: (CLLocationCoordinate2D) coord zoom: (double) zoom{
    double long n = pow(2, zoom);
    
    NSDecimalNumber * xtileDec = [[NSDecimalNumber alloc ] initWithDouble: ((coord.longitude + 180.0f) / 360.0f) * n];
    
    NSDecimalNumber * ytileDec = [[NSDecimalNumber alloc ] initWithDouble: (1 - (log(tan(DegreesToRadians(coord.latitude)) + (1/cos(DegreesToRadians(coord.latitude)))) / M_PI)) / 2 * n];
    
    
    RMTileDec tile;
    
    tile.x = xtileDec;
    tile.y = ytileDec;
    tile.zoom = zoom;
    
    return tile;
}



- (CLLocationCoordinate2D) tileToCoordinate: (RMTileDec) tile{
    
    long long n = pow(2, tile.zoom);
    
    double lon_deg = ([tile.x doubleValue] / n) * 360.0 - 180.0;
    
    
    
    double lat_rad = atan(sinh( M_PI * (1 - 2 * [tile.y doubleValue] / n)));
    double lat_deg = RadiansToDegrees(lat_rad);
    
    CLLocationCoordinate2D coord;
    
    coord.latitude = lat_deg;
    coord.longitude = lon_deg;
    
    return coord;
}

- (CLLocationCoordinate2D) convertCoordinate: (CLLocationCoordinate2D) coord{
    CLLocationCoordinate2D newCoord;
    
    RMTileDec coordTile = [self coordinateToTile:coord zoom:baseTile.zoom];
    
    NSDecimalNumber * baseTileDecX = [[NSDecimalNumber alloc] initWithDouble: baseTile.x ];
    NSDecimalNumber * baseTileDecY = [[NSDecimalNumber alloc] initWithDouble: baseTile.y ];
    
    NSDecimalNumber * multiplier = [[NSDecimalNumber alloc] initWithInt:(int)pow(2, zoomSteps)];
    
    NSDecimalNumber * xDiff = [[baseTileDecX decimalNumberBySubtracting: coordTile.x] decimalNumberByMultiplyingBy:multiplier] ;
    NSDecimalNumber * yDiff = [[baseTileDecY decimalNumberBySubtracting: coordTile.y] decimalNumberByMultiplyingBy:multiplier];
    
    
    RMTileDec newCoordTile;
    
    newCoordTile.x = [baseTileDecX decimalNumberBySubtracting:xDiff];
    newCoordTile.y = [baseTileDecY decimalNumberBySubtracting:yDiff];
    newCoordTile.zoom = coordTile.zoom;
    
    
    newCoord = [self tileToCoordinate: newCoordTile];
    
    return newCoord;
    
}

- (CLLocationCoordinate2D) reverseConvertCoordinate: (CLLocationCoordinate2D) coord{
    CLLocationCoordinate2D newCoord;
    
    RMTileDec coordTile = [self coordinateToTile:coord zoom:baseTile.zoom];
    
    NSDecimalNumber * baseTileDecX = [[NSDecimalNumber alloc] initWithDouble: baseTile.x ];
    NSDecimalNumber * baseTileDecY = [[NSDecimalNumber alloc] initWithDouble: baseTile.y ];
    
    NSDecimalNumber * multiplier = [[NSDecimalNumber alloc] initWithInt:(int)pow(2, zoomSteps)];
    
    NSDecimalNumber * xDiff = [[baseTileDecX decimalNumberBySubtracting: coordTile.x] decimalNumberByDividingBy:multiplier] ;
    NSDecimalNumber * yDiff = [[baseTileDecY decimalNumberBySubtracting: coordTile.y] decimalNumberByDividingBy:multiplier];
    
    
    RMTileDec newCoordTile;
    
    newCoordTile.x = [baseTileDecX decimalNumberBySubtracting:xDiff];
    newCoordTile.y = [baseTileDecY decimalNumberBySubtracting:yDiff];
    newCoordTile.zoom = coordTile.zoom;
    
    
    newCoord = [self tileToCoordinate: newCoordTile];
    
    return newCoord;
    
}

- (NSDecimalNumber *)abs:(NSDecimalNumber *)num {
    if ([num compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        // Number is negative. Multiply by -1
        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        return [num decimalNumberByMultiplyingBy:negativeOne];
    } else {
        return num;
    }
}

- (void) convertTileSource: (NSString *) filePath {
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    if (![db open]) {
        return;
    }
    
    
    
    FMResultSet *s = [db executeQuery:@"SELECT * FROM tiles"];
    
    NSString * allQueries = @"";
    
    
    while ([s next]) {
        
        RMTile tile;
        tile.x = [s intForColumn:@"col"];
        tile.y = [s intForColumn:@"row"];
        tile.zoom = [s intForColumn:@"zoom"];
        
        
        RMTile convertedTile;
        convertedTile = [self reverseConvertTile:tile];
        
        
        uint64_t key = RMTileKey(convertedTile);
        
        NSString * query = [NSString stringWithFormat:@"UPDATE tiles SET tilekey= '%llu', col= '%i', row= '%i', zoom= '%i'  WHERE tilekey = '%llu';", key, convertedTile.x, convertedTile.y, convertedTile.zoom, [s longLongIntForColumn:@"tilekey"]];
        
        
        
        allQueries = [allQueries stringByAppendingString:query];
        
        /*[db beginTransaction];
         BOOL updateResult = [db executeUpdate: query];
         [db commit];*/
        
    }
    
    FMResultSet *preferences = [db executeQuery:@"SELECT * FROM preferences"];
    
    CLLocationCoordinate2D topLeft, bottomRight, center;
    
    while ([preferences next]){
        NSString * query;
        
        if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.minZoom"]){
            query = [NSString stringWithFormat:@"UPDATE preferences SET value= '%i' WHERE name='%@';", [preferences intForColumn:@"value"] - zoomSteps, @"map.minZoom"];
            allQueries = [allQueries stringByAppendingString:query];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.maxZoom"]){
            query = [NSString stringWithFormat:@"UPDATE preferences SET value= '%i' WHERE name='%@';", [preferences intForColumn:@"value"] - zoomSteps, @"map.maxZoom"];
            allQueries = [allQueries stringByAppendingString:query];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.topLeft.latitude"]){
            topLeft.latitude = [preferences doubleForColumn:@"value"];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.topLeft.longitude"]){
            topLeft.longitude = [preferences doubleForColumn:@"value"];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.bottomRight.latitude"]){
            bottomRight.latitude = [preferences doubleForColumn:@"value"];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.bottomRight.longitude"]){
            bottomRight.longitude = [preferences doubleForColumn:@"value"];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.center.latitude"]){
            center.latitude = [preferences doubleForColumn:@"value"];
        }else if ([[preferences stringForColumn:@"name"] isEqualToString: @"map.coverage.center.longitude"]){
            center.longitude = [preferences doubleForColumn:@"value"];
        }
    }
    
    CLLocationCoordinate2D topLeftConverted, bottomRightConverted, centerConverted;
    
    topLeftConverted = [self convertCoordinate:topLeft];
    bottomRightConverted = [self convertCoordinate:bottomRight];
    centerConverted = [self convertCoordinate:center];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", topLeftConverted.latitude, @"map.coverage.topLeft.latitude"]];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", topLeftConverted.longitude, @"map.coverage.topLeft.longitude"]];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", bottomRightConverted.latitude, @"map.coverage.bottomRight.latitude"]];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", bottomRightConverted.longitude, @"map.coverage.bottomRight.longitude"]];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", centerConverted.latitude, @"map.coverage.center.latitude"]];
    
    allQueries = [allQueries stringByAppendingString:[NSString stringWithFormat:@"UPDATE preferences SET value= '%f' WHERE name='%@';", centerConverted.longitude, @"map.coverage.center.longitude"]];
    
    NSLog(@"%@", allQueries);
    
    
    return;
}
@end