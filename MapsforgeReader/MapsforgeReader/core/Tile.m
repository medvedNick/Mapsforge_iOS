#import "Tile.h"


/**
 * Bytes per pixel required in a map tile bitmap.
 */
char const TILE_BYTES_PER_PIXEL = 2;

/**
 * Width and height of a map tile in pixel.
 */
int const TILE_SIZE = 256;

/**
 * Size of a single uncompressed map tile bitmap in bytes.
 */
int const TILE_SIZE_IN_BYTES = TILE_SIZE * TILE_SIZE * TILE_BYTES_PER_PIXEL;
long const serialVersionUID = 1L;

@implementation Tile

@synthesize pixelX;
@synthesize pixelY;


/**
 * @param tileX
 * the X number of the tile.
 * @param tileY
 * the Y number of the tile.
 * @param zoomLevel
 * the zoom level of the tile.
 */
- (id) init:(long)_tileX tileY:(long)_tileY zoomLevel:(Byte)_zoomLevel {
  if (self = [super init]) {
    tileX = _tileX;
    tileY = _tileY;
    zoomLevel = _zoomLevel;
    [self calculateTransientValues];
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[Tile class]]) {
    return NO;
  }
  Tile * other = (Tile *)obj;
  if (tileX != other->tileX) {
    return NO;
  }
   else if (tileY != other->tileY) {
    return NO;
  }
   else if (zoomLevel != other->zoomLevel) {
    return NO;
  }
  return YES;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Tile [tileX=%d, tileY=%d, zoomLevel=%d", tileX, tileY, zoomLevel];
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + (int)(tileX ^ ((long long)tileX >> 32));
  result = 31 * result + (int)(tileY ^ ((long long)tileY >> 32));
  result = 31 * result + zoomLevel;
  return result;
}


/**
 * Calculates the values of some transient variables.
 */
- (void) calculateTransientValues {
  pixelX = tileX * TILE_SIZE;
  pixelY = tileY * TILE_SIZE;
  hashCodeValue = [self calculateHashCode];
}

/*
- (void) readObject:(ObjectInputStream *)objectInputStream {
  [objectInputStream defaultReadObject];
  [self calculateTransientValues];
}
 */

@end
