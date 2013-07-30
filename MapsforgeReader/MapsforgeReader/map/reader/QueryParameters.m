#import "QueryParameters.h"

@implementation QueryParameters

- (NSString *) description {
	return [NSString stringWithFormat:@"QueryParameters [fromBaseTileX=%lld, fromBaseTileY=%lld, fromBlockX=%lld, fromBlockY=%lld, queryTileBitmask=%d, queryZoomLevel=%d, toBaseTileX=%lld, toBaseTileY=%lld, toBlockX=%lld, toBlockY=%lld, useTileBitmask=%d]",
            fromBaseTileX, fromBaseTileY, fromBlockX, fromBlockY, queryTileBitmask, queryZoomLevel, toBaseTileX, toBaseTileY, toBlockX, toBlockY, useTileBitmask];
}

@end
