#import "BoundingBox.h"


/**
 * Conversion factor from degrees to microdegrees.
 */
double const CONVERSION_FACTOR = 1000000.0;
extern long const serialVersionUID;// = 1L;

@implementation BoundingBox

@synthesize centerPoint;
//@synthesize maxLatitude;
//@synthesize maxLongitude;
//@synthesize minLatitude;
//@synthesize minLongitude;

+ (BOOL) isBetween:(int)number min:(int)min max:(int)max {
  return min <= number && number <= max;
}


/**
 * @param minLatitudeE6
 * the minimum latitude in microdegrees (degrees * 10^6).
 * @param minLongitudeE6
 * the minimum longitude in microdegrees (degrees * 10^6).
 * @param maxLatitudeE6
 * the maximum latitude in microdegrees (degrees * 10^6).
 * @param maxLongitudeE6
 * the maximum longitude in microdegrees (degrees * 10^6).
 */
- (id) init:(int)_minLatitudeE6 minLongitudeE6:(int)_minLongitudeE6 maxLatitudeE6:(int)_maxLatitudeE6 maxLongitudeE6:(int)_maxLongitudeE6 {
  if (self = [super init]) {
    minLatitudeE6 = _minLatitudeE6;
    minLongitudeE6 = _minLongitudeE6;
    maxLatitudeE6 = _maxLatitudeE6;
    maxLongitudeE6 = _maxLongitudeE6;
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}


/**
 * @param geoPoint
 * the point whose coordinates should be checked.
 * @return true if this BoundingBox contains the given GeoPoint, false otherwise.
 */
- (BOOL) contains:(GeoPoint *)geoPoint {
  return [BoundingBox isBetween:geoPoint.latitude min:minLatitudeE6 max:maxLatitudeE6] && [BoundingBox isBetween:geoPoint.longitude min:minLongitudeE6 max:maxLongitudeE6];
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (!([obj isKindOfClass:[BoundingBox class]])) {
    return NO;
  }
  BoundingBox * other = (BoundingBox *)obj;
  if (maxLatitudeE6 != other.maxLatitude) {
    return NO;
  }
   else if (maxLongitudeE6 != other.maxLongitude) {
    return NO;
  }
   else if (minLatitudeE6 != other.minLatitude) {
    return NO;
  }
   else if (minLongitudeE6 != other.minLongitude) {
    return NO;
  }
  return YES;
}


/**
 * @return the GeoPoint at the horizontal and vertical center of this BoundingBox.
 */
- (GeoPoint *) centerPoint {
  int latitudeOffset = (maxLatitudeE6 - minLatitudeE6) / 2;
  int longitudeOffset = (maxLongitudeE6 - minLongitudeE6) / 2;
    return [[GeoPoint alloc] init:minLatitudeE6 + latitudeOffset longitudeE6:minLongitudeE6 + longitudeOffset];// autorelease];
}


/**
 * @return the maximum latitude value of this BoundingBox in degrees.
 */
- (double) maxLatitude {
  return maxLatitudeE6 / CONVERSION_FACTOR;
}


/**
 * @return the maximum longitude value of this BoundingBox in degrees.
 */
- (double) maxLongitude {
  return maxLongitudeE6 / CONVERSION_FACTOR;
}


/**
 * @return the minimum latitude value of this BoundingBox in degrees.
 */
- (double) minLatitude {
  return minLatitudeE6 / CONVERSION_FACTOR;
}


/**
 * @return the minimum longitude value of this BoundingBox in degrees.
 */
- (double) minLongitude {
  return minLongitudeE6 / CONVERSION_FACTOR;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
  NSString *desc = [NSString stringWithFormat:@"BoundingBox [minLatitudeE6=%d, minLongitudeE6=%d, maxLatitudeE6=%d, maxLongitudeE6=%d]", minLatitudeE6, minLongitudeE6, maxLatitudeE6, maxLongitudeE6];

	return desc;
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + maxLatitudeE6;
  result = 31 * result + maxLongitudeE6;
  result = 31 * result + minLatitudeE6;
  result = 31 * result + minLongitudeE6;
  return result;
}

/*
- (void) readObject:(ObjectInputStream *)objectInputStream {
  [objectInputStream defaultReadObject];
  hashCodeValue = [self calculateHashCode];
}
 */

@end
