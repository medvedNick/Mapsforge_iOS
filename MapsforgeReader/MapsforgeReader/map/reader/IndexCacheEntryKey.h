#import "SubFileParameter.h"

/**
 * An immutable container class which is the key for the index cache.
 */

@interface IndexCacheEntryKey : NSObject <NSCopying> {
  int hashCodeValue;
  long indexBlockNumber;
  SubFileParameter * subFileParameter;
}

- (id) init:(SubFileParameter *)subFileParameter indexBlockNumber:(long)indexBlockNumber;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (int) calculateHashCode;
- (id) copyWithZone:(NSZone *)zone;
@end
