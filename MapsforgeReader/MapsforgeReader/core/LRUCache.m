#import "LRUCache.h"

float const LOAD_FACTOR = 0.6f;
extern long const serialVersionUID;// = 1L;

@implementation LRUCache

+ (int) calculateInitialCapacity:(int)capacity {
  if (capacity < 0) {
	  [NSException raise:@"InvalidArgumentException" format:[NSString stringWithFormat:@"capacity must not be negative: %d", capacity]];
  }
  return (int)(capacity / LOAD_FACTOR) + 2;
}


/**
 * @param capacity
 * the maximum capacity of this cache.
 * @throws IllegalArgumentException
 * if the capacity is negative.
 */
- (id) initWithCapacity:(int)_capacity {
  if (self = [super init])
  {
	  //[super init:[self calculateInitialCapacity:capacity] param1:LOAD_FACTOR param2:YES]) {
	    capacity = _capacity;
  }
  return self;
}

- (BOOL) removeEldestEntry:(id *)eldest {
  return [self count] > capacity;
}

@end
