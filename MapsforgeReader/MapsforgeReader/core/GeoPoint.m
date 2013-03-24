#import "GeoPoint.h"
#import "MercatorProjection.h"

/**
 * Conversion factor from degrees to microdegrees.
 */
extern double const CONVERSION_FACTOR;// = 1000000;
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
    latitudeE6 = (int)(limitLatitude * CONVERSION_FACTOR);
    double limitLongitude = [MercatorProjection limitLongitude:_longitude];
    longitudeE6 = (int)(limitLongitude * CONVERSION_FACTOR);
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
- (id) init:(int)_latitudeE6 longitudeE6:(int)_longitudeE6 {
  if (self = [self init:_latitudeE6 / CONVERSION_FACTOR longitude:_longitudeE6 / CONVERSION_FACTOR]) {
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
  return latitudeE6 / CONVERSION_FACTOR;
}


/**
 * @return the longitude value of this GeoPoint in degrees.
 */
- (double) longitude {
  return longitudeE6 / CONVERSION_FACTOR;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	NSString *desc = [NSString stringWithFormat:@"GeoPoint [latitudeE6=%d, longitudeE6=%d]"];
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
