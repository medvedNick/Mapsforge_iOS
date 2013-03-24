#import "RequiredFields.h"


/**
 * Magic byte at the beginning of a valid binary map file.
 */
NSString * const BINARY_OSM_MAGIC_BYTE = @"mapsforge binary OSM";

/**
 * Maximum size of the file header in bytes.
 */
int const HEADER_SIZE_MAX = 1000000;

/**
 * Minimum size of the file header in bytes.
 */
int const HEADER_SIZE_MIN = 70;

/**
 * The name of the Mercator projection as stored in the file header.
 */
NSString * const MERCATOR = @"Mercator";

/**
 * A single whitespace character.
 */
unichar const SPACE = ' ';

/**
 * Version of the map file format which is supported by this implementation.
 */
int const SUPPORTED_FILE_VERSION = 3;

/**
 * The maximum latitude values in microdegrees.
 */
int const RF_LATITUDE_MAX = 90000000;

/**
 * The minimum latitude values in microdegrees.
 */
int const RF_LATITUDE_MIN = -90000000;

/**
 * The maximum longitude values in microdegrees.
 */
int const RF_LONGITUDE_MAX = 180000000;

/**
 * The minimum longitude values in microdegrees.
 */
int const RF_LONGITUDE_MIN = -180000000;

@implementation RequiredFields

+ (FileOpenResult *) readBoundingBox:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  int minLatitude = [readBuffer readInt];
  if (minLatitude < RF_LATITUDE_MIN || minLatitude > RF_LATITUDE_MAX) {
	  return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid minimum latitude: %d",minLatitude]];// autorelease];
  }
  int minLongitude = [readBuffer readInt];
  if (minLongitude < RF_LONGITUDE_MIN || minLongitude > RF_LONGITUDE_MAX) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid minimum longitude: %d", minLongitude]];// autorelease];
  }
  int maxLatitude = [readBuffer readInt];
  if (maxLatitude < RF_LATITUDE_MIN || maxLatitude > RF_LATITUDE_MAX) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid maximum latitude: %d",maxLatitude]];// autorelease];
  }
  int maxLongitude = [readBuffer readInt];
  if (maxLongitude < RF_LONGITUDE_MIN || maxLongitude > RF_LONGITUDE_MAX) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid maximum longitude: %d", maxLongitude]];// autorelease];
  }
  if (minLatitude > maxLatitude) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid latitude range: %d, %d", minLatitude, maxLatitude]];// autorelease];
  }
   else if (minLongitude > maxLongitude) {
       return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid longitude range: %d, %d", minLongitude, maxLongitude]] ;//autorelease];
  }
  mapFileInfoBuilder->boundingBox = [[BoundingBox alloc] init:minLatitude minLongitudeE6:minLongitude maxLatitudeE6:maxLatitude maxLongitudeE6:maxLongitude];//autorelease];
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readFileSize:(ReadBuffer *)readBuffer fileSize:(long)fileSize mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  long long headerFileSize = [readBuffer readLong];
  if (headerFileSize != fileSize) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid file size: %d", headerFileSize]];// autorelease];
  }
  mapFileInfoBuilder->fileSize = fileSize;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readFileVersion:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  int fileVersion = [readBuffer readInt];
  if (fileVersion != SUPPORTED_FILE_VERSION) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"unsupported file version: %d",fileVersion]];// autorelease];
  }
  mapFileInfoBuilder->fileVersion = fileVersion;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readMagicByte:(ReadBuffer *)readBuffer {
  int magicByteLength = [BINARY_OSM_MAGIC_BYTE length];
  if (![readBuffer readFromFile:magicByteLength + 4]) {
      return [[FileOpenResult alloc]initWithErrorMessage:[NSString stringWithFormat:@"reading magic byte has failed"]];//autorelease];
  }
  NSString * magicByte = [readBuffer readUTF8EncodedString:magicByteLength];
  if (![BINARY_OSM_MAGIC_BYTE isEqualToString:magicByte]) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid magic byte: %d", magicByte]];// autorelease];
  }
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readMapDate:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  long long mapDate = [readBuffer readLong];
  if (mapDate < 1200000000000L) {
//    return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid map date: %d", mapDate]];//autorelease];
  }
  mapFileInfoBuilder->mapDate = mapDate;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readPoiTags:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  int numberOfPoiTags = [readBuffer readShort];
  if (numberOfPoiTags < 0) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid number of POI tags: %d",numberOfPoiTags]];// autorelease];
  }
  NSMutableArray * poiTags = [[NSMutableArray alloc] initWithCapacity:numberOfPoiTags];

  for (int currentTagId = 0; currentTagId < numberOfPoiTags; ++currentTagId) {
    [poiTags addObject:[NSNull null]];
  }    
    
  for (int currentTagId = 0; currentTagId < numberOfPoiTags; ++currentTagId) {
    NSString * tag = [readBuffer readUTF8EncodedString];
    if (tag == nil) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"POI tag must not be null: %d",currentTagId]];// autorelease];
    }
    [poiTags replaceObjectAtIndex:currentTagId withObject:[[MFTag alloc] initWithTag:tag]];//autorelease]];
  }

  mapFileInfoBuilder->poiTags = poiTags;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readProjectionName:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  NSString * projectionName = [readBuffer readUTF8EncodedString];
  if (![MERCATOR isEqualToString:projectionName]) {
    return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"unsupported projection: %@",projectionName]];//autorelease];
  }
  mapFileInfoBuilder->projectionName = projectionName;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readRemainingHeader:(ReadBuffer *)readBuffer {
  int remainingHeaderSize = [readBuffer readInt];
  if (remainingHeaderSize < HEADER_SIZE_MIN || remainingHeaderSize > HEADER_SIZE_MAX) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid remaining header size: %d",remainingHeaderSize]];// autorelease];
  }
  if (![readBuffer readFromFile:remainingHeaderSize]) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"reading header data has failed: %d",remainingHeaderSize]];// autorelease];
  }
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readTilePixelSize:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  int tilePixelSize = [readBuffer readShort];
  if (tilePixelSize != TILE_SIZE) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"unsupported tile pixel size: %d",tilePixelSize]];// autorelease];
  }
  mapFileInfoBuilder->tilePixelSize = tilePixelSize;
  return [FileOpenResult SUCCESS];
}

+ (FileOpenResult *) readWayTags:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  int numberOfWayTags = [readBuffer readShort];
  if (numberOfWayTags < 0) {
      return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid number of way tags: %d",numberOfWayTags]];// autorelease];
  }
  NSMutableArray * wayTags = [[NSMutableArray alloc] initWithCapacity:numberOfWayTags];

  for (int currentTagId = 0; currentTagId < numberOfWayTags; ++currentTagId) {
    [wayTags addObject:[NSNull null]];
  }
    
  for (int currentTagId = 0; currentTagId < numberOfWayTags; ++currentTagId) {
    NSString * tag = [readBuffer readUTF8EncodedString];
    if (tag == nil) {
//        [wayTags release];
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"way tag must not be null: %d",currentTagId]];// autorelease];
    }
    [wayTags replaceObjectAtIndex:currentTagId withObject:[[MFTag alloc] initWithTag:tag]/* autorelease]*/];
  }

  mapFileInfoBuilder->wayTags = wayTags;
  return [FileOpenResult SUCCESS];
}

- (id) init {
  if (self = [super init]) {
	  [NSException raise:@"IllegalStateException" format:@"initializing RequiredField is forbidden"];
  }
  return self;
}

@end
