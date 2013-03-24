#import "GeoPoint.h"

/**
 * A MapPosition represents an immutable pair of {@link GeoPoint} and zoom level.
 */

@interface MapPosition : NSObject /*<Serializable>*/ {

  /**
   * The map position.
 */
  GeoPoint * geoPoint;

  /**
   * The zoom level.
 */
  Byte zoomLevel;

  /**
   * The hash code of this object.
 */
  int hashCodeValue;
}

- (id) init:(GeoPoint *)geoPoint zoomLevel:(char)zoomLevel;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (int) calculateHashCode;
@end
