//
//  OSPCoordinateRect.h
//  OpenStreetPad
//
//  Created by Thomas Davie on 13/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef struct
{
    double x;
    double y;
} OSPCoordinate2D;

typedef struct
{
    OSPCoordinate2D origin;
    OSPCoordinate2D size;
}
OSPCoordinateRect;

typedef struct
{
    NSUInteger x;
    NSUInteger y;
    uint8_t zoom;
} OSPTile;


double longitudeToPixelX(double longitude, short zoomLevel);
double latitudeToPixelY(double latitude, short zoomLevel);
long tileToPixel(long tileNumber);
OSPCoordinate2D OSPCoordinate2DMake(double x, double y);
OSPCoordinate2D OSPCoordinate2DProjectLocation(CLLocationCoordinate2D l, short zoomLevel, long tileX, long tileY);
CLLocationCoordinate2D OSPCoordinate2DUnproject(OSPCoordinate2D l);
NSString *NSStringFromOSPCoordinate2D(OSPCoordinate2D l);

extern const OSPCoordinateRect OSPCoordinateRectZero;

OSPCoordinateRect OSPCoordinateRectMake(double x, double y, double w, double h);
OSPCoordinateRect OSPCoordinateRectUnion(OSPCoordinateRect a, OSPCoordinateRect b);

double OSPCoordinateRectGetMinLongitude(OSPCoordinateRect r);
double OSPCoordinateRectGetMaxLongitude(OSPCoordinateRect r);
double OSPCoordinateRectGetMinLatitude(OSPCoordinateRect r);
double OSPCoordinateRectGetMaxLatitude(OSPCoordinateRect r);
double OSPCoordinateRectGetWidth(OSPCoordinateRect r);
double OSPCoordinateRectGetHeight(OSPCoordinateRect r);

double OSPCoordinateRectArea(OSPCoordinateRect r);

OSPCoordinate2D OSPCoordinateRectGetMinCoord(OSPCoordinateRect r);
OSPCoordinate2D OSPCoordinateRectGetMaxCoord(OSPCoordinateRect r);

BOOL OSPCoordinateRectContainsRect(OSPCoordinateRect a, OSPCoordinateRect b);
BOOL OSPCoordinateRectIntersectsRect(OSPCoordinateRect a, OSPCoordinateRect b);

OSPCoordinateRect OSPCoordinateRectOutset(OSPCoordinateRect r, double xOutset, double yOutset);

NSArray *OSPCoordinateRectSubtract(OSPCoordinateRect a, OSPCoordinateRect b);

NSArray *NSArrayOfTilesFromCoordinateRect(OSPCoordinateRect r, double maxOverspill);
OSPCoordinateRect OSPCoordinateRectFromTile(OSPTile t);

NSString *NSStringFromOSPCoordinateRect(OSPCoordinateRect r);

BOOL OSPTileEqual(OSPTile a, OSPTile b);

@protocol OSPBounded <NSObject>

- (OSPCoordinateRect)bounds;

@end
