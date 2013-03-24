#import "MapFileInfo.h"

@implementation MapFileInfo

- (id) initWithMapFileInfoBuilder:(MapFileInfoBuilder *)mapFileInfoBuilder {
  if (self = [super init]) {
    comment = mapFileInfoBuilder->optionalFields->comment;
    createdBy = mapFileInfoBuilder->optionalFields->createdBy;
    debugFile = mapFileInfoBuilder->optionalFields->isDebugFile;
    fileSize = mapFileInfoBuilder->fileSize;
    fileVersion = mapFileInfoBuilder->fileVersion;
    languagePreference = mapFileInfoBuilder->optionalFields->languagePreference;
    boundingBox = mapFileInfoBuilder->boundingBox;
    mapCenter = [boundingBox centerPoint];
    mapDate = mapFileInfoBuilder->mapDate;
    numberOfSubFiles = mapFileInfoBuilder->numberOfSubFiles;
    poiTags = mapFileInfoBuilder->poiTags;
    projectionName = mapFileInfoBuilder->projectionName;
    startPosition = mapFileInfoBuilder->optionalFields->startPosition;
    startZoomLevel = mapFileInfoBuilder->optionalFields->startZoomLevel;
    tilePixelSize = mapFileInfoBuilder->tilePixelSize;
    wayTags = mapFileInfoBuilder->wayTags;
  }
  return self;
}

//- (void) dealloc {
//  [boundingBox release];
//  [comment release];
//  [createdBy release];
//  [languagePreference release];
//  [mapCenter release];
//  [poiTags release];
//  [projectionName release];
//  [startPosition release];
//  [startZoomLevel release];
//  [wayTags release];
//  [super dealloc];
//}

@end
