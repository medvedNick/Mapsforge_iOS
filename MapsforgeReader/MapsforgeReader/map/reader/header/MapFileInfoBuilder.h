#import "BoundingBox.h"
#import "MFTag.h"
#import "OptionalFields.h"
#import "MapFileInfo.h"

@class MapFileInfo, OptionalFields;

@interface MapFileInfoBuilder : NSObject {
@public
  BoundingBox * boundingBox;
  long long fileSize;
  int fileVersion;
  long long mapDate;
  char numberOfSubFiles;
  OptionalFields * optionalFields;
  NSArray * poiTags;
  NSString * projectionName;
  int tilePixelSize;
  NSArray * wayTags;
}

- (MapFileInfo *) build;
@end
