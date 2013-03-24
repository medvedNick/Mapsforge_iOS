//#import "IOException.h"
#import "ReadBuffer.h"
#import "MapFileInfo.h"
#import "MapFileInfoBuilder.h"
#import "SubFileParameter.h"
#import "FileOpenResult.h"

/**
 * Reads and validates the header data from a binary map file.
 */

@class FileOpenResult, MapFileInfo, MapFileInfoBuilder;

@interface MapFileHeader : NSObject {
@public
  MapFileInfo * mapFileInfo;
  NSMutableArray * subFileParameters;
  Byte zoomLevelMaximum;
  Byte zoomLevelMinimum;
}

@property(nonatomic, retain, readonly) MapFileInfo * mapFileInfo;
- (Byte) getQueryZoomLevel:(Byte)zoomLevel;
- (SubFileParameter *) getSubFileParameter:(int)queryZoomLevel;
- (FileOpenResult *) readHeader:(ReadBuffer *)readBuffer fileSize:(long)fileSize;
- (FileOpenResult *) readSubFileParameters:(ReadBuffer *)readBuffer fileSize:(long)fileSize mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
- (void) updateZoomLevelInformation:(SubFileParameter *)subFileParameter;
@end
