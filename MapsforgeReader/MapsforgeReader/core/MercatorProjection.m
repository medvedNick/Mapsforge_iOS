#import "MercatorProjection.h"
#import "Tile.h"

/**
 * The circumference of the earth at the equator in meters.
 */
double const EARTH_CIRCUMFERENCE = 40075016.686;

/**
 * Maximum possible latitude coordinate of the map.
 */
double const LATITUDE_MAX = 85.05112877980659;

/**
 * Minimum possible latitude coordinate of the map.
 */
double const LATITUDE_MIN = -LATITUDE_MAX;

/**
 * Maximum possible longitude coordinate of the map.
 */
double const LONGITUDE_MAX = 180;

/**
 * Minimum possible longitude coordinate of the map.
 */
double const LONGITUDE_MIN = -LONGITUDE_MAX;

@implementation MercatorProjection


/**
 * Calculates the distance on the ground that is represented by a single pixel on the map.
 * 
 * @param latitude
 * the latitude coordinate at which the resolution should be calculated.
 * @param zoomLevel
 * the zoom level at which the resolution should be calculated.
 * @return the ground resolution at the given latitude and zoom level.
 */
+ (double) calculateGroundResolution:(double)latitude zoomLevel:(char)zoomLevel {
  return cos(latitude * (M_PI / 180)) * EARTH_CIRCUMFERENCE / ((long)TILE_SIZE << zoomLevel);
}


/**
 * Converts a latitude coordinate (in degrees) to a pixel Y coordinate at a certain zoom level.
 * 
 * @param latitude
 * the latitude coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the pixel Y coordinate of the latitude value.
 */
+ (double) latitudeToPixelY:(double)latitude zoomLevel:(char)zoomLevel {
  double sinLatitude = sin(latitude * (M_PI / 180));
  return (0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * M_PI)) * ((long)TILE_SIZE << zoomLevel);
}


/**
 * Converts a latitude coordinate (in degrees) to a tile Y number at a certain zoom level.
 * 
 * @param latitude
 * the latitude coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the tile Y number of the latitude value.
 */
+ (long) latitudeToTileY:(double)latitude zoomLevel:(char)zoomLevel {
  return [self pixelYToTileY:[self latitudeToPixelY:latitude zoomLevel:zoomLevel] zoomLevel:zoomLevel];
}


/**
 * @param latitude
 * the latitude value which should be checked.
 * @return the given latitude value, limited to the possible latitude range.
 */
+ (double) limitLatitude:(double)latitude {
  return MAX(MIN(latitude, LATITUDE_MAX), LATITUDE_MIN);
}


/**
 * @param longitude
 * the longitude value which should be checked.
 * @return the given longitude value, limited to the possible longitude range.
 */
+ (double) limitLongitude:(double)longitude {
  return MAX(MIN(longitude, LONGITUDE_MAX), LONGITUDE_MIN);
}


/**
 * Converts a longitude coordinate (in degrees) to a pixel X coordinate at a certain zoom level.
 * 
 * @param longitude
 * the longitude coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the pixel X coordinate of the longitude value.
 */
+ (double) longitudeToPixelX:(double)longitude zoomLevel:(char)zoomLevel {
  return (longitude + 180) / 360 * ((long)TILE_SIZE << zoomLevel);
}


/**
 * Converts a longitude coordinate (in degrees) to the tile X number at a certain zoom level.
 * 
 * @param longitude
 * the longitude coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the tile X number of the longitude value.
 */
+ (long) longitudeToTileX:(double)longitude zoomLevel:(char)zoomLevel {
  return [self pixelXToTileX:[self longitudeToPixelX:longitude zoomLevel:zoomLevel] zoomLevel:zoomLevel];
}


/**
 * Converts a pixel X coordinate at a certain zoom level to a longitude coordinate.
 * 
 * @param pixelX
 * the pixel X coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the longitude value of the pixel X coordinate.
 */
+ (double) pixelXToLongitude:(double)pixelX zoomLevel:(char)zoomLevel {
  return 360 * ((pixelX / ((long)TILE_SIZE << zoomLevel)) - 0.5);
}


/**
 * Converts a pixel X coordinate to the tile X number.
 * 
 * @param pixelX
 * the pixel X coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the tile X number.
 */
+ (long) pixelXToTileX:(double)pixelX zoomLevel:(char)zoomLevel {
  return (long)MIN(MAX(pixelX / TILE_SIZE, 0) , pow(2, zoomLevel) - 1);
}


/**
 * Converts a pixel Y coordinate at a certain zoom level to a latitude coordinate.
 * 
 * @param pixelY
 * the pixel Y coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the latitude value of the pixel Y coordinate.
 */
+ (double) pixelYToLatitude:(double)pixelY zoomLevel:(char)zoomLevel {
  double y = 0.5 - (pixelY / ((long)TILE_SIZE << zoomLevel));
  return 90 - 360 * atan(exp(-y * (2 * M_PI))) / M_PI;
}


/**
 * Converts a pixel Y coordinate to the tile Y number.
 * 
 * @param pixelY
 * the pixel Y coordinate that should be converted.
 * @param zoomLevel
 * the zoom level at which the coordinate should be converted.
 * @return the tile Y number.
 */
+ (long) pixelYToTileY:(double)pixelY zoomLevel:(char)zoomLevel {
  return (long)MIN(MAX(pixelY / TILE_SIZE, 0), pow(2, zoomLevel) - 1);
}


/**
 * Converts a tile X number at a certain zoom level to a longitude coordinate.
 * 
 * @param tileX
 * the tile X number that should be converted.
 * @param zoomLevel
 * the zoom level at which the number should be converted.
 * @return the longitude value of the tile X number.
 */
+ (double) tileXToLongitude:(long)tileX zoomLevel:(char)zoomLevel {
  return [self pixelXToLongitude:tileX * TILE_SIZE zoomLevel:zoomLevel];
}


/**
 * Converts a tile Y number at a certain zoom level to a latitude coordinate.
 * 
 * @param tileY
 * the tile Y number that should be converted.
 * @param zoomLevel
 * the zoom level at which the number should be converted.
 * @return the latitude value of the tile Y number.
 */
+ (double) tileYToLatitude:(long)tileY zoomLevel:(char)zoomLevel {
  return [self pixelYToLatitude:tileY * TILE_SIZE zoomLevel:zoomLevel];
}

- (id) init {
  if (self = [super init]) {
	  [NSException raise:@"IllegalStateException!" format:@"Exception in MercatorProjection.m"];
  }
  return self;
}

@end
