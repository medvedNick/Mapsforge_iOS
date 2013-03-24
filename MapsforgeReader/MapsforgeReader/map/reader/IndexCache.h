#import "LRUCache.h"
#import "SubFileParameter.h"

/**
 * A cache for database index blocks with a fixed size and LRU policy.
 */

@interface IndexCache : NSObject {
  NSMutableDictionary * map;
  NSData * randomAccessFile;
}

- (id) init:(NSData *)randomAccessFile capacity:(int)capacity;
- (void) destroy;
- (long) getIndexEntry:(SubFileParameter *)subFileParameter blockNumber:(long)blockNumber;
@end
