#import "GeoPoint.h"

/**
 * A BoundingBox represents an immutable set of two latitude and two longitude coordinates.
 */

@interface BoundingBox : NSObject /*<Serializable>*/ {

@public
  /**
   * The maximum latitude value of this BoundingBox in microdegrees (degrees * 10^6).
 */
  int maxLatitudeE6;

  /**
   * The maximum longitude value of this BoundingBox in microdegrees (degrees * 10^6).
 */
  int maxLongitudeE6;

  /**
   * The minimum latitude value of this BoundingBox in microdegrees (degrees * 10^6).
 */
  int minLatitudeE6;

  /**
   * The minimum longitude value of this BoundingBox in microdegrees (degrees * 10^6).
 */
  int minLongitudeE6;

  /**
   * The hash code of this object.
 */
  int hashCodeValue;
}

@property(nonatomic, retain, readonly) GeoPoint * centerPoint;
@property(nonatomic, readonly) double maxLatitude;
@property(nonatomic, readonly) double maxLongitude;
@property(nonatomic, readonly) double minLatitude;
@property(nonatomic, readonly) double minLongitude;
- (id) init:(int)minLatitudeE6 minLongitudeE6:(int)minLongitudeE6 maxLatitudeE6:(int)maxLatitudeE6 maxLongitudeE6:(int)maxLongitudeE6;
- (BOOL) contains:(GeoPoint *)geoPoint;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (int) calculateHashCode;
@end
