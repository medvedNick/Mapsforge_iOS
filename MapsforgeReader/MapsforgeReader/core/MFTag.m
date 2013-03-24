#import "MFTag.h"

unichar const KEY_VALUE_SEPARATOR = '=';
extern long const serialVersionUID;// = 1L;

@implementation MFTag


/**
 * @param tag
 * the textual representation of the tag.
 */
- (id) initWithTag:(NSString *)tag {
  if (self = [super init]) {
    NSRange range = [tag rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c", KEY_VALUE_SEPARATOR]]];
	  int splitPosition = range.location;
    key = [tag substringToIndex: splitPosition]; //retain];
    value = [tag substringFromIndex:splitPosition + 1];// retain]; // TODO: так ли это?!
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}


/**
 * @param key
 * the key of the tag.
 * @param value
 * the value of the tag.
 */
- (id) init:(NSString *)_key value:(NSString *)_value {
  if (self = [super init]) {
    key = _key;
    value = _value;
    hashCodeValue = [self calculateHashCode];
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)obj {
  if (self == obj) {
    return YES;
  }
   else if (![obj isKindOfClass:[MFTag class]]) {
    return NO;
  }
  MFTag * other = (MFTag *)obj;
  if (key == nil && other->key != nil) {
    return NO;
  }
   else if (key != nil && ![key isEqualToString:other->key]) {
    return NO;
  }
   else if (value == nil && other->value != nil) {
    return NO;
  }
   else if (value != nil && ![value isEqualToString:other->value]) {
    return NO;
  }
  return YES;
}

- (int) hash {
  return hashCodeValue;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Tag [key=%@, value=%@]", key, value];
}


/**
 * @return the hash code of this object.
 */
- (int) calculateHashCode {
  int result = 7;
  result = 31 * result + ((key == nil) ? 0 : [key hash]);
  result = 31 * result + ((value == nil) ? 0 : [value hash]);
  return result;
}

/*
- (void) readObject:(ObjectInputStream *)objectInputStream {
  [objectInputStream defaultReadObject];
  hashCodeValue = [self calculateHashCode];
}
 */

//- (void) dealloc {
//  [key release];
//  [value release];
//  [super dealloc];
//}

@end
