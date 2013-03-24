/**
 * A tag represents an immutable key-value pair.
 */

@interface MFTag : NSObject /*<Serializable>*/ {

@public
  /**
   * The key of this tag.
 */
  NSString * key;

  /**
   * The value of this tag.
 */
  NSString * value;
  int hashCodeValue;
}

- (id) initWithTag:(NSString *)tag;
- (id) init:(NSString *)key value:(NSString *)value;
- (BOOL) isEqualTo:(NSObject *)obj;
- (int) hash;
- (NSString *) description;
- (int) calculateHashCode;
@end
