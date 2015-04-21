/**
 * A GeoPoint represents an immutable pair of latitude and longitude coordinates.
 */

@interface GeoPoint : NSObject /*<Comparable, Serializable>*/ {

  /**
   * The latitude value of this GeoPoint in microdegrees (degrees * 10^6).
 */
  double latitudeE6;

  /**
   * The longitude value of this GeoPoint in microdegrees (degrees * 10^6).
 */
  double longitudeE6;

  /**
   * The hash code of this object.
 */
  int hashCodeValue;
}

@property(nonatomic, readonly) double latitude;
@property(nonatomic, readonly) double longitude;
- (id) init:(double)latitude longitude:(double)longitude;
- (id) init:(double)latitudeE6 longitudeE6:(double)longitudeE6;
- (int) compareTo:(GeoPoint *)geoPoint;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (int) calculateHashCode;
@end
