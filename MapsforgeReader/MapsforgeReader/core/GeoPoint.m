#import "GeoPoint.h"
#import "MercatorProjection.h"

/**
 * Conversion factor from degrees to microdegrees.
 */
extern long const serialVersionUID;// = 1L;

@implementation GeoPoint

@synthesize latitude;
@synthesize longitude;


/**
 * @param latitude
 * the latitude in degrees, will be limited to the possible latitude range.
 * @param longitude
 * the longitude in degrees, will be limited to the possible longitude range.
 */
- (id) init:(double)_latitude longitude:(double)_longitude {
  if (self = [super init]) {
    double limitLatitude = [MercatorProjection limitLatitude:_latitude];
    latitudeE6 = (limitLatitude);
    double limitLongitude = [MercatorProjection limitLongitude:_longitude];
    longitudeE6 = (limitLongitude);
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}


/**
 * @param latitudeE6
 * the latitude in microdegrees (degrees * 10^6), will be limited to the possible latitude range.
 * @param longitudeE6
 * the longitude in microdegrees (degrees * 10^6), will be limited to the possible longitude range.
 */
- (id) init:(double)_latitudeE6 longitudeE6:(double)_longitudeE6 {
  if (self = [self init:_latitudeE6 longitude:_longitudeE6]) {
  }
  return self;
}

- (int) compareTo:(GeoPoint *)geoPoint {
  if (longitudeE6 > geoPoint.longitude) {
    return 1;
  }
   else if (longitudeE6 < geoPoint.longitude) {
    return -1;
  }
   else if (latitudeE6 > geoPoint.latitude) {
    return 1;
  }
   else if (latitudeE6 < geoPoint.latitude) {
    return -1;
  }
  return 0;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[GeoPoint class]]) {
    return NO;
  }
  GeoPoint * other = (GeoPoint *)obj;
  if (latitudeE6 != other.latitude) {
    return NO;
  }
   else if (longitudeE6 != other.longitude) {
    return NO;
  }
  return YES;
}


/**
 * @return the latitude value of this GeoPoint in degrees.
 */
- (double) latitude {
  return latitudeE6;
}


/**
 * @return the longitude value of this GeoPoint in degrees.
 */
- (double) longitude {
  return longitudeE6;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	NSString *desc = [NSString stringWithFormat:@"GeoPoint [latitudeE6=%f, longitudeE6=%f]", latitudeE6, longitudeE6];
	return desc;
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + latitudeE6;
  result = 31 * result + longitudeE6;
  return result;
}

/*
- (void) readObject:(ObjectInputStream *)objectInputStream {
  [objectInputStream defaultReadObject];
  hashCodeValue = [self calculateHashCode];
}
 */

@end
