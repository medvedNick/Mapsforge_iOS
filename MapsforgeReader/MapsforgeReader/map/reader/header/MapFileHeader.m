#import "MapFileHeader.h"
#import "RequiredFields.h"

/**
 * Maximum valid base zoom level of a sub-file.
 */
int const BASE_ZOOM_LEVEL_MAX = 26;

/**
 * Minimum size of the file header in bytes.
 */
extern int const HEADER_SIZE_MIN;// = 70;

/**
 * Length of the debug signature at the beginning of the index.
 */
char const SIGNATURE_LENGTH_INDEX = 16;

/**
 * A single whitespace character.
 */
extern unichar const SPACE;// = ' ';

@implementation MapFileHeader

@synthesize mapFileInfo;


/**
 * @param zoomLevel
 * the originally requested zoom level.
 * @return the closest possible zoom level which is covered by a sub-file.
 */
- (Byte) getQueryZoomLevel:(Byte)zoomLevel {
  if (zoomLevel > zoomLevelMaximum) {
    return zoomLevelMaximum;
  }
   else if (zoomLevel < zoomLevelMinimum) {
    return zoomLevelMinimum;
  }
  return zoomLevel;
}


/**
 * @param queryZoomLevel
 * the zoom level for which the sub-file parameters are needed.
 * @return the sub-file parameters for the given zoom level.
 */
- (SubFileParameter *) getSubFileParameter:(int)queryZoomLevel {
  return [subFileParameters objectAtIndex:queryZoomLevel];
}


/**
 * Reads and validates the header block from the map file.
 * 
 * @param readBuffer
 * the ReadBuffer for the file data.
 * @param fileSize
 * the size of the map file in bytes.
 * @return a FileOpenResult containing an error message in case of a failure.
 * @throws IOException
 * if an error occurs while reading the file.
 */
- (FileOpenResult *) readHeader:(ReadBuffer *)readBuffer fileSize:(long)fileSize {
  FileOpenResult * fileOpenResult = [RequiredFields readMagicByte:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readRemainingHeader:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  MapFileInfoBuilder * mapFileInfoBuilder = [[MapFileInfoBuilder alloc] init];// autorelease];
  fileOpenResult = [RequiredFields readFileVersion:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readFileSize:readBuffer fileSize:fileSize mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readMapDate:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readBoundingBox:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readTilePixelSize:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readProjectionName:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [OptionalFields readOptionalFields:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readPoiTags:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [RequiredFields readWayTags:readBuffer mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [self readSubFileParameters:readBuffer fileSize:fileSize mapFileInfoBuilder:mapFileInfoBuilder];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  mapFileInfo = [mapFileInfoBuilder build];
  return [FileOpenResult SUCCESS];
}

- (FileOpenResult *) readSubFileParameters:(ReadBuffer *)readBuffer fileSize:(long)fileSize mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  Byte numberOfSubFiles = [readBuffer readByte];
  if (numberOfSubFiles < 1) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid number of sub-files: %d", numberOfSubFiles]];// autorelease];
  }
  mapFileInfoBuilder->numberOfSubFiles = numberOfSubFiles;
  NSMutableArray * tempSubFileParameters = [NSMutableArray arrayWithCapacity:numberOfSubFiles];
  for (int i = 0; i < numberOfSubFiles; ++i) {
      [tempSubFileParameters addObject:[NSNull null]];
  }
  zoomLevelMinimum = SCHAR_MAX;
  zoomLevelMaximum = SCHAR_MIN;

  for (Byte currentSubFile = 0; currentSubFile < numberOfSubFiles; ++currentSubFile) {
      SubFileParameterBuilder * subFileParameterBuilder = [[SubFileParameterBuilder alloc] init];// autorelease];
    Byte baseZoomLevel = [readBuffer readByte];
    if (baseZoomLevel < 0 || baseZoomLevel > BASE_ZOOM_LEVEL_MAX) {
		return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid base zooom level: %d",baseZoomLevel]];// autorelease];
    }
    subFileParameterBuilder->baseZoomLevel = baseZoomLevel;
    Byte zoomLevelMin = [readBuffer readByte];
    if (zoomLevelMin < 0 || zoomLevelMin > 22) {
		return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid base zooom level: %d",baseZoomLevel]];// autorelease];
    }
    subFileParameterBuilder->zoomLevelMin = zoomLevelMin;
    Byte zoomLevelMax = [readBuffer readByte];
    if (zoomLevelMax < 0 || zoomLevelMax > 22) {
		return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid zooom level: %d",zoomLevelMin]];// autorelease];
    }
    subFileParameterBuilder->zoomLevelMax = zoomLevelMax;
    if (zoomLevelMin > zoomLevelMax) {
		return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid zooom level:%d", zoomLevelMax]];// autorelease];
    }
    long startAddress = [readBuffer readLong];
    if (startAddress < HEADER_SIZE_MIN || startAddress >= fileSize) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid start address:%ld", startAddress]];// autorelease];
    }
    subFileParameterBuilder->startAddress = startAddress;
    long indexStartAddress = startAddress;
    if (mapFileInfoBuilder->optionalFields->isDebugFile) {
      indexStartAddress += SIGNATURE_LENGTH_INDEX;
    }
    subFileParameterBuilder->indexStartAddress = indexStartAddress;
    long subFileSize = [readBuffer readLong];
    if (subFileSize < 1) {
		return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid sub-file size: %ld",subFileSize]];// autorelease];
    }
    subFileParameterBuilder->subFileSize = subFileSize;
    subFileParameterBuilder->boundingBox = mapFileInfoBuilder->boundingBox;
    [tempSubFileParameters replaceObjectAtIndex:currentSubFile withObject:[subFileParameterBuilder build]];
    [self updateZoomLevelInformation:[tempSubFileParameters objectAtIndex:currentSubFile]];
  }

    subFileParameters = [[NSMutableArray alloc] initWithCapacity:zoomLevelMaximum+1];//[NSMutableArray arrayWithCapacity:zoomLevelMaximum+1];

  for (int i = 0; i < zoomLevelMaximum; ++i) {
    [subFileParameters addObject:[NSNull null]];
  }
    
  for (int currentMapFile = 0; currentMapFile < numberOfSubFiles; ++currentMapFile) {
    SubFileParameter * subFileParameter = [tempSubFileParameters objectAtIndex:currentMapFile];

    for (Byte zoomLevel = subFileParameter->zoomLevelMin; zoomLevel <= subFileParameter->zoomLevelMax; ++zoomLevel) {
		[subFileParameters replaceObjectAtIndex:zoomLevel withObject:subFileParameter];
    }

  }

  return [FileOpenResult SUCCESS];
}

- (void) updateZoomLevelInformation:(SubFileParameter *)subFileParameter {
  if (zoomLevelMinimum > subFileParameter->zoomLevelMin) {
    zoomLevelMinimum = subFileParameter->zoomLevelMin;
  }
  if (zoomLevelMaximum < subFileParameter->zoomLevelMax) {
    zoomLevelMaximum = subFileParameter->zoomLevelMax;
  }
}

//- (void) dealloc {
//  [mapFileInfo release];
//  [subFileParameters release];
//  [super dealloc];
//}

@end
