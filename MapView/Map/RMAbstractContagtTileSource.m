//
//  RMAbstractContagtTileSource.m
//  MapView
//
//  Created by contagt GmbH on 06.03.15.
//
//

#import "RMAbstractContagtTileSource.h"

@implementation RMAbstractContagtTileSource
{
    RMFractalTileProjection *_tileProjection;
}

@synthesize minZoom = _minZoom, maxZoom = _maxZoom, cacheable = _cacheable, opaque = _opaque;

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    _tileProjection = nil;
    
    // http://wiki.openstreetmap.org/index.php/FAQ#What_is_the_map_scale_for_a_particular_zoom_level_of_the_map.3F
    self.minZoom = kDefaultMinTileZoom;
    self.maxZoom = kDefaultMaxTileZoom;
    
    self.cacheable = YES;
    self.opaque = YES;
    
    return self;
}

- (RMSphericalTrapezium)latitudeLongitudeBoundingBox
{
    return kDefaultLatLonBoundingBox;
}

- (UIImage *)imageForTile:(RMTile)tile inCache:(RMTileCache *)tileCache
{
    @throw [NSException exceptionWithName:@"RMAbstractMethodInvocation"
                                   reason:@"imageForTile:inCache: invoked on RMAbstractMercatorTileSource. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}

- (BOOL)tileSourceHasTile:(RMTile)tile
{
    return YES;
}

- (void)cancelAllDownloads
{
}

- (RMProjection *)projection
{
    return [RMProjection googleProjection];
}

- (RMFractalTileProjection *)mercatorToTileProjection
{
    if ( ! _tileProjection)
    {
        
        _tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[self projection]
                                                              tileSideLength:kDefaultTileSize
                                                                     maxZoom:kDefaultMinTileZoom
                                                                     minZoom:kDefaultMaxTileZoom];
    }
    
    return _tileProjection;
}

- (void)didReceiveMemoryWarning
{
    LogMethod();
}

#pragma mark -

- (NSUInteger)tileSideLength
{
    return kDefaultTileSize;
}

- (NSString *)uniqueTilecacheKey
{
    @throw [NSException exceptionWithName:@"RMAbstractMethodInvocation"
                                   reason:@"uniqueTilecacheKey invoked on RMAbstractMercatorTileSource. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}

- (NSString *)shortName
{
    @throw [NSException exceptionWithName:@"RMAbstractMethodInvocation"
                                   reason:@"shortName invoked on RMAbstractMercatorTileSource. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}

- (NSString *)longDescription
{
    return [self shortName];
}

- (NSString *)shortAttribution
{
    @throw [NSException exceptionWithName:@"RMAbstractMethodInvocation"
                                   reason:@"shortAttribution invoked on RMAbstractMercatorTileSource. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}

- (NSString *)longAttribution
{
    return [self shortAttribution];
}

@end
