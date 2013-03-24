#import "GeoPoint.h"
#import "ReadBuffer.h"
#import "MapFileInfoBuilder.h"
#import "FileOpenResult.h"

@class FileOpenResult, MapFileInfoBuilder;

@interface OptionalFields : NSObject {
@public
  NSString * comment;
  NSString * createdBy;
  BOOL hasComment;
  BOOL hasCreatedBy;
  BOOL hasLanguagePreference;
  BOOL hasStartPosition;
  BOOL hasStartZoomLevel;
  BOOL isDebugFile;
  NSString * languagePreference;
  GeoPoint * startPosition;
  NSNumber * startZoomLevel;
}

+ (FileOpenResult *) readOptionalFields:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder;
- (id) initWithFlags:(char)flags;
- (FileOpenResult *) readOptionalFields:(ReadBuffer *)readBuffer;
@end
