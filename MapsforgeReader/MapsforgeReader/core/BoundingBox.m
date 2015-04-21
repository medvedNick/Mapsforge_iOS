#import "BoundingBox.h"


/**
 * Conversion factor from degrees to microdegrees.
 */
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
- (id) init:(double)_minLatitudeE6 minLongitudeE6:(double)_minLongitudeE6 maxLatitudeE6:(double)_maxLatitudeE6 maxLongitudeE6:(double)_maxLongitudeE6 {
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
  double latitudeOffset = (maxLatitudeE6 - minLatitudeE6) / 2;
  double longitudeOffset = (maxLongitudeE6 - minLongitudeE6) / 2;
    return [[GeoPoint alloc] init:minLatitudeE6 + latitudeOffset longitudeE6:minLongitudeE6 + longitudeOffset];// autorelease];
}


/**
 * @return the maximum latitude value of this BoundingBox in degrees.
 */
- (double) maxLatitude {
  return maxLatitudeE6;
}


/**
 * @return the maximum longitude value of this BoundingBox in degrees.
 */
- (double) maxLongitude {
  return maxLongitudeE6;
}


/**
 * @return the minimum latitude value of this BoundingBox in degrees.
 */
- (double) minLatitude {
  return minLatitudeE6;
}


/**
 * @return the minimum longitude value of this BoundingBox in degrees.
 */
- (double) minLongitude {
  return minLongitudeE6;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
  NSString *desc = [NSString stringWithFormat:@"BoundingBox [minLatitudeE6=%f, minLongitudeE6=%f, maxLatitudeE6=%f, maxLongitudeE6=%f]", minLatitudeE6, minLongitudeE6, maxLatitudeE6, maxLongitudeE6];

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
