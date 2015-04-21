//
//  RMZoomConverter.h
//  LayeredMap
//
//  Created by Tomáš Kohout on 03.03.13.
//
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import <CoreLocation/CoreLocation.h>


typedef struct{
    __unsafe_unretained NSDecimalNumber * x;
    __unsafe_unretained NSDecimalNumber * y;
    int zoom;
}RMTileDec;

@interface RMZoomConverter : NSObject
-(id)initWithBaseCoord:(CLLocationCoordinate2D)aBaseCoord minZoom: (int) minZoom zoomSteps: (int) aZoomSteps;

- initWithBaseTile: (RMTile) aBaseTile zoomSteps: (int) aZoomSteps;

- (RMTile) convertTile: (RMTile) tile;
- (RMTile) reverseConvertTile: (RMTile) tile;

- (CLLocationCoordinate2D) convertCoordinate: (CLLocationCoordinate2D) coord;
- (CLLocationCoordinate2D) reverseConvertCoordinate: (CLLocationCoordinate2D) coord;

- (void) convertTileSource: (NSString *) filePath;

- (double) convertZoom: (double) zoom;

@property (nonatomic, readonly) int maxZoom;
@property (nonatomic, readonly) int minZoom;

@end