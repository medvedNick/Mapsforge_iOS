#import "QueryCalculations.h"
#import "QueryParameters.h"

@implementation QueryCalculations

+ (int) getFirstLevelTileBitmask:(Tile *)tile {
  if (tile->tileX % 2 == 0 && tile->tileY % 2 == 0) {
    return 0xcc00;
  }
   else if (tile->tileX % 2 == 1 && tile->tileY % 2 == 0) {
    return 0x3300;
  }
   else if (tile->tileX % 2 == 0 && tile->tileY % 2 == 1) {
    return 0xcc;
  }
   else {
    return 0x33;
  }
}

+ (int) getSecondLevelTileBitmaskLowerLeft:(long)subtileX subtileY:(long)subtileY {
  if (subtileX % 2 == 0 && subtileY % 2 == 0) {
    return 0x80;
  }
   else if (subtileX % 2 == 1 && subtileY % 2 == 0) {
    return 0x40;
  }
   else if (subtileX % 2 == 0 && subtileY % 2 == 1) {
    return 0x8;
  }
   else {
    return 0x4;
  }
}

+ (int) getSecondLevelTileBitmaskLowerRight:(long)subtileX subtileY:(long)subtileY {
  if (subtileX % 2 == 0 && subtileY % 2 == 0) {
    return 0x20;
  }
   else if (subtileX % 2 == 1 && subtileY % 2 == 0) {
    return 0x10;
  }
   else if (subtileX % 2 == 0 && subtileY % 2 == 1) {
    return 0x2;
  }
   else {
    return 0x1;
  }
}

+ (int) getSecondLevelTileBitmaskUpperLeft:(long)subtileX subtileY:(long)subtileY {
  if (subtileX % 2 == 0 && subtileY % 2 == 0) {
    return 0x8000;
  }
   else if (subtileX % 2 == 1 && subtileY % 2 == 0) {
    return 0x4000;
  }
   else if (subtileX % 2 == 0 && subtileY % 2 == 1) {
    return 0x800;
  }
   else {
    return 0x400;
  }
}

+ (int) getSecondLevelTileBitmaskUpperRight:(long)subtileX subtileY:(long)subtileY {
  if (subtileX % 2 == 0 && subtileY % 2 == 0) {
    return 0x2000;
  }
   else if (subtileX % 2 == 1 && subtileY % 2 == 0) {
    return 0x1000;
  }
   else if (subtileX % 2 == 0 && subtileY % 2 == 1) {
    return 0x200;
  }
   else {
    return 0x100;
  }
}

+ (void) calculateBaseTiles:(QueryParameters *)queryParameters tile:(Tile *)tile subFileParameter:(SubFileParameter *)subFileParameter {
  if (tile->zoomLevel < subFileParameter->baseZoomLevel) {
    int zoomLevelDifference = subFileParameter->baseZoomLevel - tile->zoomLevel;
    queryParameters->fromBaseTileX = tile->tileX << zoomLevelDifference;
    queryParameters->fromBaseTileY = tile->tileY << zoomLevelDifference;
    queryParameters->toBaseTileX = queryParameters->fromBaseTileX + (1 << zoomLevelDifference) - 1;
    queryParameters->toBaseTileY = queryParameters->fromBaseTileY + (1 << zoomLevelDifference) - 1;
    queryParameters->useTileBitmask = NO;
  }
   else if (tile->zoomLevel > subFileParameter->baseZoomLevel) {
    int zoomLevelDifference = tile->zoomLevel - subFileParameter->baseZoomLevel;
    queryParameters->fromBaseTileX = tile->tileX >> zoomLevelDifference;
    queryParameters->fromBaseTileY = tile->tileY >> zoomLevelDifference;
    queryParameters->toBaseTileX = queryParameters->fromBaseTileX;
    queryParameters->toBaseTileY = queryParameters->fromBaseTileY;
    queryParameters->useTileBitmask = YES;
    queryParameters->queryTileBitmask = [self calculateTileBitmask:tile zoomLevelDifference:zoomLevelDifference];
  }
   else {
    queryParameters->fromBaseTileX = tile->tileX;
    queryParameters->fromBaseTileY = tile->tileY;
    queryParameters->toBaseTileX = queryParameters->fromBaseTileX;
    queryParameters->toBaseTileY = queryParameters->fromBaseTileY;
    queryParameters->useTileBitmask = NO;
  }
}

+ (void) calculateBlocks:(QueryParameters *)queryParameters subFileParameter:(SubFileParameter *)subFileParameter {
  queryParameters->fromBlockX = MAX(queryParameters->fromBaseTileX - subFileParameter->boundaryTileLeft,0);
  queryParameters->fromBlockY = MAX(queryParameters->fromBaseTileY - subFileParameter->boundaryTileTop,0);
  queryParameters->toBlockX = MIN(queryParameters->toBaseTileX - subFileParameter->boundaryTileLeft,subFileParameter->blocksWidth - 1);
  queryParameters->toBlockY = MIN(queryParameters->toBaseTileY - subFileParameter->boundaryTileTop,subFileParameter->blocksHeight - 1);
}

+ (int) calculateTileBitmask:(Tile *)tile zoomLevelDifference:(int)zoomLevelDifference {
  if (zoomLevelDifference == 1) {
    return [self getFirstLevelTileBitmask:tile];
  }
  long subtileX = tile->tileX >> (zoomLevelDifference - 2);
  long subtileY = tile->tileY >> (zoomLevelDifference - 2);
  long parentTileX = subtileX >> 1;
  long parentTileY = subtileY >> 1;
  if (parentTileX % 2 == 0 && parentTileY % 2 == 0) {
    return [self getSecondLevelTileBitmaskUpperLeft:subtileX subtileY:subtileY];
  }
   else if (parentTileX % 2 == 1 && parentTileY % 2 == 0) {
    return [self getSecondLevelTileBitmaskUpperRight:subtileX subtileY:subtileY];
  }
   else if (parentTileX % 2 == 0 && parentTileY % 2 == 1) {
    return [self getSecondLevelTileBitmaskLowerLeft:subtileX subtileY:subtileY];
  }
   else {
    return [self getSecondLevelTileBitmaskLowerRight:subtileX subtileY:subtileY];
  }
}

- (id) init {
  if (self = [super init]) {
      [NSException raise:@"IllegalStateException int -init in QueryCalculations" format:@""];
  }
  return self;
}

@end
