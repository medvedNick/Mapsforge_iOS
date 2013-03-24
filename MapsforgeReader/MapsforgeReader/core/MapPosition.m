#import "MapPosition.h"

extern long const serialVersionUID;// = 1L;

@implementation MapPosition


/**
 * @param geoPoint
 * the map position.
 * @param zoomLevel
 * the zoom level.
 */
- (id) init:(GeoPoint *)_geoPoint zoomLevel:(char)_zoomLevel {
  if (self = [super init]) {
    geoPoint = _geoPoint;
    zoomLevel = _zoomLevel;
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[MapPosition class]]) {
    return NO;
  }
  MapPosition * other = (MapPosition *)obj;
  if (geoPoint == nil) {
    if (other->geoPoint != nil) {
      return NO;
    }
  }
   else if (![geoPoint isEqualTo:other->geoPoint]) {
    return NO;
  }
  if (zoomLevel != other->zoomLevel) {
    return NO;
  }
  return YES;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	NSString *desc = [NSString stringWithFormat:@"MapPosition [geoPoint=%@, zoomLevel=%d]", [geoPoint description], zoomLevel];
	return desc;
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + ((geoPoint == nil) ? 0 : [geoPoint hash]);
  result = 31 * result + zoomLevel;
  return result;
}
/*
- (void) readObject:(ObjectInputStream *)objectInputStream {
  [objectInputStream defaultReadObject];
  hashCodeValue = [self calculateHashCode];
}
 */
/*
- (void) dealloc {
  [geoPoint release];
  [super dealloc];
}*/

@end
