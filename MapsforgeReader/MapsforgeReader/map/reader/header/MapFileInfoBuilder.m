#import "MapFileInfoBuilder.h"
#import "MapFileInfo.h"

@implementation MapFileInfoBuilder

- (MapFileInfo *) build {
    return [[MapFileInfo alloc] initWithMapFileInfoBuilder:self];// autorelease];
}

//- (void) dealloc {
//  [boundingBox release];
//  [optionalFields release];
//  [poiTags release];
//  [projectionName release];
//  [wayTags release];
//  [super dealloc];
//}

@end
