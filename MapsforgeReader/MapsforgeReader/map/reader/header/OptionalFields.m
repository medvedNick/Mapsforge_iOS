#import "OptionalFields.h"
#import "FileOpenResult.h"
#import "RequiredFields.h"

/**
 * Bitmask for the comment field in the file header.
 */
int const HEADER_BITMASK_COMMENT = 0x08;

/**
 * Bitmask for the created by field in the file header.
 */
int const HEADER_BITMASK_CREATED_BY = 0x04;

/**
 * Bitmask for the debug flag in the file header.
 */
int const HEADER_BITMASK_DEBUG = 0x80;

/**
 * Bitmask for the language preference field in the file header.
 */
int const HEADER_BITMASK_LANGUAGE_PREFERENCE = 0x10;

/**
 * Bitmask for the start position field in the file header.
 */
int const HEADER_BITMASK_START_POSITION = 0x40;

/**
 * Bitmask for the start zoom level field in the file header.
 */
int const HEADER_BITMASK_START_ZOOM_LEVEL = 0x20;

/**
 * The length of the language preference string.
 */
int const LANGUAGE_PREFERENCE_LENGTH = 2;

/**
 * Maximum valid start zoom level.
 */
int const START_ZOOM_LEVEL_MAX = 22;



extern int const RF_LATITUDE_MAX;
extern int const RF_LATITUDE_MIN;
extern int const RF_LONGITUDE_MAX;
extern int const RF_LONGITUDE_MIN;


@implementation OptionalFields

+ (FileOpenResult *) readOptionalFields:(ReadBuffer *)readBuffer mapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  OptionalFields * optionalFields = [[OptionalFields alloc] initWithFlags:[readBuffer readByte]];// autorelease];
  mapFileInfoBuilder->optionalFields = optionalFields;
  FileOpenResult * fileOpenResult = [optionalFields readOptionalFields:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  return [FileOpenResult SUCCESS];
}

- (id) initWithFlags:(char)flags {
  if (self = [super init]) {
    isDebugFile = (flags & HEADER_BITMASK_DEBUG) != 0;
    hasStartPosition = (flags & HEADER_BITMASK_START_POSITION) != 0;
    hasStartZoomLevel = (flags & HEADER_BITMASK_START_ZOOM_LEVEL) != 0;
    hasLanguagePreference = (flags & HEADER_BITMASK_LANGUAGE_PREFERENCE) != 0;
    hasComment = (flags & HEADER_BITMASK_COMMENT) != 0;
    hasCreatedBy = (flags & HEADER_BITMASK_CREATED_BY) != 0;
  }
  return self;
}

- (FileOpenResult *) readLanguagePreference:(ReadBuffer *)readBuffer {
  if (hasLanguagePreference) {
    NSString * countryCode = [readBuffer readUTF8EncodedString];
    if ([countryCode length] != LANGUAGE_PREFERENCE_LENGTH) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid language preference: %@", countryCode]];// autorelease];
    }
    languagePreference = countryCode;
  }
  return [FileOpenResult SUCCESS];
}

- (double) microDegreesToDegrees:(double)mdegrees {
    return mdegrees / 1000000.0;
}

- (FileOpenResult *) readMapStartPosition:(ReadBuffer *)readBuffer {
  if (hasStartPosition) {
    double mapStartLatitude = [self microDegreesToDegrees:[readBuffer readInt]];
    if (mapStartLatitude < RF_LATITUDE_MIN || mapStartLatitude > RF_LATITUDE_MAX) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid map start latitude: %f",mapStartLatitude]];// autorelease];
    }
    double mapStartLongitude = [self microDegreesToDegrees:[readBuffer readInt]];
    if (mapStartLongitude < RF_LONGITUDE_MIN || mapStartLongitude > RF_LONGITUDE_MAX) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid map start longitude: %f",mapStartLongitude]];// autorelease];
    }
    startPosition = [[GeoPoint alloc] init:mapStartLatitude longitudeE6:mapStartLongitude];// autorelease];
  }
  return [FileOpenResult SUCCESS];
}

- (FileOpenResult *) readMapStartZoomLevel:(ReadBuffer *)readBuffer {
  if (hasStartZoomLevel) {
    char mapStartZoomLevel = [readBuffer readByte];
    if (mapStartZoomLevel < 0 || mapStartZoomLevel > START_ZOOM_LEVEL_MAX) {
        return [[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"invalid map start zoom level: %d",mapStartZoomLevel]];// autorelease];
    }
    startZoomLevel = [NSNumber numberWithInt:mapStartZoomLevel];
  }
  return [FileOpenResult SUCCESS];
}

- (FileOpenResult *) readOptionalFields:(ReadBuffer *)readBuffer {
  FileOpenResult * fileOpenResult = [self readMapStartPosition:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [self readMapStartZoomLevel:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  fileOpenResult = [self readLanguagePreference:readBuffer];
  if (![fileOpenResult success]) {
    return fileOpenResult;
  }
  if (hasComment) {
    comment = [readBuffer readUTF8EncodedString];
  }
  if (hasCreatedBy) {
    createdBy = [readBuffer readUTF8EncodedString];
  }
  return [FileOpenResult SUCCESS];
}

//- (void) dealloc {
//  [comment release];
//  [createdBy release];
//  [languagePreference release];
//  [startPosition release];
//  [startZoomLevel release];
//  [super dealloc];
//}

@end
