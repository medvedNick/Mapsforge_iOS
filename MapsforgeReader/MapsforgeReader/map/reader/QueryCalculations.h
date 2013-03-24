#import "Tile.h"
#import "SubFileParameter.h"
#import "QueryParameters.h"

@class QueryParameters;

@interface QueryCalculations : NSObject {
}

+ (void) calculateBaseTiles:(QueryParameters *)queryParameters tile:(Tile *)tile subFileParameter:(SubFileParameter *)subFileParameter;
+ (void) calculateBlocks:(QueryParameters *)queryParameters subFileParameter:(SubFileParameter *)subFileParameter;
+ (int) calculateTileBitmask:(Tile *)tile zoomLevelDifference:(int)zoomLevelDifference;
@end
