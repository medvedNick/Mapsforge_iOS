#import "BoundingBox.h"
#import "SubFileParameter.h"

@class SubFileParameter;

@interface SubFileParameterBuilder : NSObject {
@public
  Byte baseZoomLevel;
  BoundingBox * boundingBox;
  long indexStartAddress;
  long startAddress;
  long subFileSize;
  Byte zoomLevelMax;
  Byte zoomLevelMin;
}

- (SubFileParameter *) build;
@end
