
/**
 * An implementation of the spherical Mercator projection.
 */


/**
 * The circumference of the earth at the equator in meters.
 */
extern double const EARTH_CIRCUMFERENCE;

/**
 * Maximum possible latitude coordinate of the map.
 */
extern double const LATITUDE_MAX;

/**
 * Minimum possible latitude coordinate of the map.
 */
extern double const LATITUDE_MIN;

/**
 * Maximum possible longitude coordinate of the map.
 */
extern double const LONGITUDE_MAX;

/**
 * Minimum possible longitude coordinate of the map.
 */
extern double const LONGITUDE_MIN;

@interface MercatorProjection : NSObject {
}

+ (double) calculateGroundResolution:(double)latitude zoomLevel:(char)zoomLevel;
+ (double) latitudeToPixelY:(double)latitude zoomLevel:(char)zoomLevel;
+ (long) latitudeToTileY:(double)latitude zoomLevel:(char)zoomLevel;
+ (double) limitLatitude:(double)latitude;
+ (double) limitLongitude:(double)longitude;
+ (double) longitudeToPixelX:(double)longitude zoomLevel:(char)zoomLevel;
+ (long) longitudeToTileX:(double)longitude zoomLevel:(char)zoomLevel;
+ (double) pixelXToLongitude:(double)pixelX zoomLevel:(char)zoomLevel;
+ (long) pixelXToTileX:(double)pixelX zoomLevel:(char)zoomLevel;
+ (double) pixelYToLatitude:(double)pixelY zoomLevel:(char)zoomLevel;
+ (long) pixelYToTileY:(double)pixelY zoomLevel:(char)zoomLevel;
+ (long double) tileXToLongitude:(long)tileX zoomLevel:(char)zoomLevel;
+ (long double) tileYToLatitude:(long)tileY zoomLevel:(char)zoomLevel;
+ (long) tileToPixel:(long) tileNumber;
+ (long double) microDegreesToDegrees:(long double)mdegrees;
@end
