#import "MercatorProjection.h"
#import "MFTag.h"
#import "Tile.h"
#import "FileOpenResult.h"
#import "MapFileHeader.h"
#import "MapFileInfo.h"
#import "SubFileParameter.h"
#import "IndexCache.h"
#import "MapFileHeader.h"
#import "MapFileInfo.h"
#import "MapDatabaseCallback.h"
#import "QueryParameters.h"

/**
 * A class for reading binary map files.
 * <p>
 * This class is not thread-safe. Each thread should use its own instance.
 * 
 * @see <a href="http://code.google.com/p/mapsforge/wiki/SpecificationBinaryMapFile">Specification</a>
 */

@class MapFileInfo, MapFileHeader;
@protocol MapDatabaseCallback;

@interface MapDatabase : NSObject {
  IndexCache * databaseIndexCache;
  long fileSize;
  NSString * inputFile;
  NSData * inputData;
  MapFileHeader * mapFileHeader;
  ReadBuffer * readBuffer;
  NSString * signatureBlock;
  NSString * signaturePoi;
  NSString * signatureWay;
  int tileLatitude;
  int tileLongitude;
}

@property(nonatomic, retain, readonly) MapFileInfo * mapFileInfo;
- (void) closeFile;
- (void) executeQuery:(Tile *)tile mapDatabaseCallback:(id<MapDatabaseCallback>)mapDatabaseCallback;
- (BOOL) hasOpenFile;
- (BOOL) openFile:(NSString *)mapFile;
- (void) prepareExecution;
- (void) processBlocks:(id<MapDatabaseCallback>)mapDatabaseCallback queryParameters:(QueryParameters *)queryParameters subFileParameter:(SubFileParameter *)subFileParameter;
- (BOOL) processBlockSignature;
- (int **) readZoomTable:(SubFileParameter *)subFileParameter;
- (BOOL) processPOIs:(id<MapDatabaseCallback>)mapDatabaseCallback numberOfPois:(int)numberOfPois;
- (BOOL) processWays:(QueryParameters *)queryParameters mapDatabaseCallback:(id<MapDatabaseCallback>)mapDatabaseCallback numberOfWays:(int)numberOfWays;
- (float *) readOptionalLabelPosition:(BOOL)featureLabelPosition;
- (int) readOptionalWayDataBlocksByte:(BOOL)featureWayDataBlocksByte;
- (int **) processWayDataBlock:(BOOL)doubleDeltaEncoding andLength:(int**)length;
@end
