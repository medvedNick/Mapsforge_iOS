#import "MFTag.h"

/**
 * Callback methods which can be triggered from the {@link MapDatabase}.
 */

@protocol MapDatabaseCallback <NSObject>
- (void) renderPointOfInterest:(char)layer latitude:(int)latitude longitude:(int)longitude tags:(NSMutableArray *)tags;
- (void) renderWaterBackground;
- (void) renderWay:(char)layer labelPosition:(float *)labelPosition tags:(NSMutableArray *)tags wayNodes:(float**)wayNodes;
- (void) addNode:(int)nodeId latitude:(int)latitude longitude:(int)longitude tags:(NSMutableDictionary *)tags;
- (void) addWay:(int)wayId nodes:(int **)nodes length:(int*)length labelPosition:(float*)labelPosition tags:(NSMutableDictionary *)tags layer:(int)layer;
@end
