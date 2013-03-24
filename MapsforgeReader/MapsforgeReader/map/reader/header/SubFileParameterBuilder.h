#import "BoundingBox.h"
#import "SubFileParameter.h"

@class SubFileParameter;

@interface SubFileParameterBuilder : NSObject {
@public
  Byte baseZoomLevel;
  BoundingBox * boundingBox;
  long long indexStartAddress;
  long long startAddress;
  long long subFileSize;
  Byte zoomLevelMax;
  Byte zoomLevelMin;
}

- (SubFileParameter *) build;
@end
