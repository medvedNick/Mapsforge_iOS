#import "MFTag.h"

/**
 * Callback methods which can be triggered from the {@link MapDatabase}.
 */

@protocol MapDatabaseCallback <NSObject>
- (void) renderPointOfInterest:(char)layer latitude:(long double)latitude longitude:(long double)longitude tags:(NSMutableArray *)tags;
- (void) renderWaterBackground;
- (void) renderWay:(char)layer labelPosition:(float *)labelPosition tags:(NSMutableArray *)tags wayNodes:(float**)wayNodes;
- (void) addNode:(int)nodeId latitude:(long double)latitude longitude:(long double)longitude tags:(NSMutableDictionary *)tags;
- (void) addWay:(int)wayId nodes:(long double **)nodes length:(int*)length labelPosition:(float*)labelPosition tags:(NSMutableDictionary *)tags layer:(int)layer x:(long)x y:(long)y;
@end
