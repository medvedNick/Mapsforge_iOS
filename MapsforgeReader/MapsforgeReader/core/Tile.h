/**
 * A tile represents a rectangular part of the world map. All tiles can be identified by their X and Y number together
 * with their zoom level. The actual area that a tile covers on a map depends on the underlying map projection.
 */


/**
 * Bytes per pixel required in a map tile bitmap.
 */
extern char const TILE_BYTES_PER_PIXEL;

/**
 * Width and height of a map tile in pixel.
 */
extern int const TILE_SIZE;

/**
 * Size of a single uncompressed map tile bitmap in bytes.
 */
extern int const TILE_SIZE_IN_BYTES;

@interface Tile : NSObject /*<Serializable>*/ {
@public
  /**
   * The X number of this tile.
 */
  long tileX;

  /**
   * The Y number of this tile.
 */
  long tileY;

  /**
   * The Zoom level of this tile.
 */
  Byte zoomLevel;
  int hashCodeValue;
  long pixelX;
  long pixelY;
}

@property(nonatomic, readonly) long pixelX;
@property(nonatomic, readonly) long pixelY;
- (id) init:(long)tileX tileY:(long)tileY zoomLevel:(Byte)zoomLevel;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (void) calculateTransientValues;
@end
