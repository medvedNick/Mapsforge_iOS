//#import "IOException.h"
#import "BoundingBox.h"
#import "MFTag.h"
#import "Tile.h"
#import "ReadBuffer.h"
#import "MapFileInfoBuilder.h"
#import "FileOpenResult.h"

@interface RequiredFields : NSObject {
}

+ (FileOpenResult *) readBoundingBox:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readFileSize:(ReadBuffer *)readBuffer fileSize:(long)fileSize mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readFileVersion:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readMagicByte:(ReadBuffer *)readBuffer;
+ (FileOpenResult *) readMapDate:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readPoiTags:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readProjectionName:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readRemainingHeader:(ReadBuffer *)readBuffer;
+ (FileOpenResult *) readTilePixelSize:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
+ (FileOpenResult *) readWayTags:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
@end
