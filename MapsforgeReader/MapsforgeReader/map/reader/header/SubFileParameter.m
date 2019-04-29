#import "SubFileParameter.h"

/**
 * Number of bytes a single index entry consists of.
 */
char const BYTES_PER_INDEX_ENTRY = 5;

/**
 * Divisor for converting coordinates stored as integers to double values.
 */
double const COORDINATES_DIVISOR = 1.0; //1000000.0

@implementation SubFileParameter

- (id) initWithSubFileParameterBuilder:(SubFileParameterBuilder *)subFileParameterBuilder {
  if (self = [super init]) {
    startAddress = subFileParameterBuilder->startAddress;
    indexStartAddress = subFileParameterBuilder->indexStartAddress;
    subFileSize = subFileParameterBuilder->subFileSize;
    baseZoomLevel = subFileParameterBuilder->baseZoomLevel;
    zoomLevelMin = subFileParameterBuilder->zoomLevelMin;
    zoomLevelMax = subFileParameterBuilder->zoomLevelMax;
    hashCodeValue = [self calculateHashCode];
    boundaryTileBottom = [MercatorProjection latitudeToTileY:subFileParameterBuilder->boundingBox->minLatitudeE6 zoomLevel:baseZoomLevel];
    boundaryTileLeft = [MercatorProjection longitudeToTileX:subFileParameterBuilder->boundingBox->minLongitudeE6 zoomLevel:baseZoomLevel];
    boundaryTileTop = [MercatorProjection latitudeToTileY:subFileParameterBuilder->boundingBox->maxLatitudeE6 zoomLevel:baseZoomLevel];
    boundaryTileRight = [MercatorProjection longitudeToTileX:subFileParameterBuilder->boundingBox->maxLongitudeE6 zoomLevel:baseZoomLevel];
    blocksWidth = boundaryTileRight - boundaryTileLeft + 1;
    blocksHeight = boundaryTileBottom - boundaryTileTop + 1;
    numberOfBlocks = blocksWidth * blocksHeight;
    indexEndAddress = indexStartAddress + numberOfBlocks * BYTES_PER_INDEX_ENTRY;
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[SubFileParameter class]]) {
    return NO;
  }
  SubFileParameter * other = (SubFileParameter *)obj;
  if (startAddress != other->startAddress) {
    return NO;
  }
   else if (subFileSize != other->subFileSize) {
    return NO;
  }
   else if (baseZoomLevel != other->baseZoomLevel) {
    return NO;
  }
  return YES;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"SubFileParameter [baseZoomLevel=%d, blocksHeight=%ld, blocksWidth=%ld, boundaryTileBottom=%ld, boundaryTileLeft=%ld, boundaryTileRight=%ld, boundaryTileTop=%ld, indexStartAddress=%ld, numberOfBlocks=%ld, startAddress=%ld, subFileSize=%ld, zoomLevelMax=%d, zoomLevelMin=%d]", baseZoomLevel,blocksHeight,blocksWidth,boundaryTileBottom,boundaryTileLeft,boundaryTileRight,boundaryTileTop,indexStartAddress,numberOfBlocks,startAddress,subFileSize,zoomLevelMax,zoomLevelMin];
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + (int)(startAddress ^ (startAddress >> 32));
  result = 31 * result + (int)(subFileSize ^ (subFileSize >> 32));
  result = 31 * result + baseZoomLevel;
  return result;
}

@end
