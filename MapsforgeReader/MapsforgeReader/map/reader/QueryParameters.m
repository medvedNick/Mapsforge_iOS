#import "QueryParameters.h"

@implementation QueryParameters

- (NSString *) description {
	return [NSString stringWithFormat:@"QueryParameters [fromBaseTileX=%d, fromBaseTileY=%d, fromBlockX=%d, fromBlockY=%d, queryTileBitmask=%d, queryTileBitmask=%d, queryZoomLevel=%d, toBaseTileX=%d, toBaseTileY=%d, toBlockX=%d, toBlockY=%d, useTileBitmask=%d]", fromBaseTileX, fromBaseTileY, fromBlockX, fromBlockY, queryTileBitmask, queryZoomLevel, toBaseTileX, toBaseTileY, toBlockX, toBlockY, useTileBitmask];
}

@end
