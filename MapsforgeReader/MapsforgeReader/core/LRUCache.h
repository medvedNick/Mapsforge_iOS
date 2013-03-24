/**
 * An LRUCache with a fixed size and an access-order policy. Old mappings are automatically removed from the cache when
 * new mappings are added. This implementation uses an {@link LinkedHashMap} internally.
 * 
 * @param <K>
 * the type of the map key, see {@link Map}.
 * @param <V>
 * the type of the map value, see {@link Map}.
 */

@interface LRUCache : NSMutableArray {
  int capacity;
}

- (id) initWithCapacity:(int)capacity;
- (BOOL) removeEldestEntry:(id *)eldest;
@end
