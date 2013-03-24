
@interface QueryParameters : NSObject {
@public
  long long fromBaseTileX;
  long long fromBaseTileY;
  long long fromBlockX;
  long long fromBlockY;
  int queryTileBitmask;
  int queryZoomLevel;
  long long toBaseTileX;
  long long toBaseTileY;
  long long toBlockX;
  long long toBlockY;
  BOOL useTileBitmask;
}

- (NSString *) description;
@end
