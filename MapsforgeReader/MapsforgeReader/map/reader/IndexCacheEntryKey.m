#import "IndexCacheEntryKey.h"

@implementation IndexCacheEntryKey


/**
 * Creates an immutable key to be stored in a map.
 * 
 * @param subFileParameter
 * the parameters of the map file.
 * @param indexBlockNumber
 * the number of the index block.
 */
- (id) init:(SubFileParameter *)_subFileParameter indexBlockNumber:(long)_indexBlockNumber {
  if (self = [super init]) {
    subFileParameter = _subFileParameter;
    indexBlockNumber = _indexBlockNumber;
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[IndexCacheEntryKey class]]) {
    return NO;
  }
  IndexCacheEntryKey * other = (IndexCacheEntryKey *)obj;
  if (subFileParameter == nil && other->subFileParameter != nil) {
    return NO;
  }
   else if (subFileParameter != nil && ![subFileParameter isEqualTo:other->subFileParameter]) {
    return NO;
  }
   else if (indexBlockNumber != other->indexBlockNumber) {
    return NO;
  }
  return YES;
}

- (int) hash {
  return hashCodeValue;
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + ((subFileParameter == nil) ? 0 : [subFileParameter hash]);
  result = 31 * result + (int)(indexBlockNumber ^ ((long long)indexBlockNumber >> 32));
  return result;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

//- (void) dealloc {
//  [subFileParameter release];
//  [super dealloc];
//}

@end
