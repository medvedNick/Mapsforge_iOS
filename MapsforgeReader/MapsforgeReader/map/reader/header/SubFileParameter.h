#import "MercatorProjection.h"
#import "SubFileParameterBuilder.h"

/**
 * Holds all parameters of a sub-file.
 */

@class SubFileParameterBuilder;

/**
 * Number of bytes a single index entry consists of.
 */
extern char const BYTES_PER_INDEX_ENTRY;

@interface SubFileParameter : NSObject {
@public
  /**
   * Base zoom level of the sub-file, which equals to one block.
 */
  Byte baseZoomLevel;

  /**
   * Vertical amount of blocks in the grid.
 */
  long long blocksHeight;

  /**
   * Horizontal amount of blocks in the grid.
 */
  long long blocksWidth;

  /**
   * Y number of the tile at the bottom boundary in the grid.
 */
  long long boundaryTileBottom;

  /**
   * X number of the tile at the left boundary in the grid.
 */
  long long boundaryTileLeft;

  /**
   * X number of the tile at the right boundary in the grid.
 */
  long long boundaryTileRight;

  /**
   * Y number of the tile at the top boundary in the grid.
 */
  long long boundaryTileTop;

  /**
   * Absolute end address of the index in the enclosing file.
 */
  long long indexEndAddress;

  /**
   * Absolute start address of the index in the enclosing file.
 */
  long long indexStartAddress;

  /**
   * Total number of blocks in the grid.
 */
  long long numberOfBlocks;

  /**
   * Absolute start address of the sub-file in the enclosing file.
 */
  long long startAddress;

  /**
   * Size of the sub-file in bytes.
 */
  long long subFileSize;

  /**
   * Maximum zoom level for which the block entries tables are made.
 */
  Byte zoomLevelMax;

  /**
   * Minimum zoom level for which the block entries tables are made.
 */
  Byte zoomLevelMin;

  /**
   * Stores the hash code of this object.
 */
  int hashCodeValue;
}

- (id) initWithSubFileParameterBuilder:(SubFileParameterBuilder *)subFileParameterBuilder;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (int) calculateHashCode;
@end
