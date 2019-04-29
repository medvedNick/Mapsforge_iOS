//
//  RMAbstractContagtTileSource.h
//  MapView
//
//  Created by contagt GmbH on 06.03.15.
//
//

#import "RMTileSource.h"
#import "RMFractalTileProjection.h"

#pragma mark --- begin constants ---

#define kDefaultTileSize 256
#define kDefaultMinTileZoom 17
#define kDefaultMaxTileZoom 23
#define kDefaultLatLonBoundingBox ((RMSphericalTrapezium){.northEast = {.latitude = 90.0, .longitude = 180.0}, .southWest = {.latitude = -90.0, .longitude = -180.0}})

#pragma mark --- end constants ---

@interface RMAbstractContagtTileSource : NSObject <RMTileSource>

@end
