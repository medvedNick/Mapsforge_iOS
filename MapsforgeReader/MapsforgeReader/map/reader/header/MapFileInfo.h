#import "BoundingBox.h"
#import "GeoPoint.h"
#import "MFTag.h"
#import "MapDatabase.h"
#import "MapFileInfoBuilder.h"

/**
 * Contains the immutable metadata of a map file.
 * 
 * @see MapDatabase#getMapFileInfo()
 */

@class MapFileInfoBuilder;

@interface MapFileInfo : NSObject {

@public    

  /**
   * The bounding box of the map file.
 */
  BoundingBox * boundingBox;

  /**
   * The comment field of the map file (may be null).
 */
  NSString * comment;

  /**
   * The created by field of the map file (may be null).
 */
  NSString * createdBy;

  /**
   * True if the map file includes debug information, false otherwise.
 */
  BOOL debugFile;

  /**
   * The size of the map file, measured in bytes.
 */
  long long fileSize;

  /**
   * The file version number of the map file.
 */
  int fileVersion;

  /**
   * The preferred language for names as defined in ISO 3166-1 (may be null).
 */
  NSString * languagePreference;

  /**
   * The center point of the map file.
 */
  GeoPoint * mapCenter;

  /**
   * The date of the map data in milliseconds since January 1, 1970.
 */
  long long mapDate;

  /**
   * The number of sub-files in the map file.
 */
  char numberOfSubFiles;

  /**
   * The POI tags.
 */
  NSArray * poiTags;

  /**
   * The name of the projection used in the map file.
 */
  NSString * projectionName;

  /**
   * The map start position from the file header (may be null).
 */
  GeoPoint * startPosition;

  /**
   * The map start zoom level from the file header (may be null).
 */
  NSNumber * startZoomLevel;

  /**
   * The size of the tiles in pixels.
 */
  int tilePixelSize;

  /**
   * The way tags.
 */
  NSArray * wayTags;
}

- (id) initWithMapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
@end
