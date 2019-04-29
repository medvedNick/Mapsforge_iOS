#import "Deserializer.h"

@implementation Deserializer


/**
 * Converts five bytes of a byte array to an unsigned long.
 * <p>
 * The byte order is big-endian.
 * 
 * @param buffer
 * the byte array.
 * @param offset
 * the offset in the array.
 * @return the long value.
 */
+ (long long) getFiveBytesLong:(Byte *)buffer offset:(long)offset {
  return (long long)(buffer[offset] & 0xffL) << 32 | (long long)(buffer[offset + 1] & 0xffL) << 24 | (buffer[offset + 2] & 0xffL) << 16 | (buffer[offset + 3] & 0xffL) << 8 | (buffer[offset + 4] & 0xffL);
}


/**
 * Converts four bytes of a byte array to a signed int.
 * <p>
 * The byte order is big-endian.
 * 
 * @param buffer
 * the byte array.
 * @param offset
 * the offset in the array.
 * @return the int value.
 */
+ (int) getInt:(Byte *)buffer offset:(int)offset {
    return buffer[offset] << 24 | (buffer[offset + 1] & 0xff) << 16 | (buffer[offset + 2] & 0xff) << 8 | (buffer[offset + 3] & 0xff);
}


/**
 * Converts eight bytes of a byte array to a signed long.
 * <p>
 * The byte order is big-endian.
 * 
 * @param buffer
 * the byte array.
 * @param offset
 * the offset in the array.
 * @return the long value.
 */
+ (long long) getLong:(Byte *)buffer offset:(int)offset {
    return (long long)(buffer[offset] & 0xff) << 56 | (long long)(buffer[offset + 1] & 0xff) << 48 | (long long)(buffer[offset + 2] & 0xff) << 40 | (long long)(buffer[offset + 3] & 0xff) << 32 | (buffer[offset + 4] & 0xff) << 24 | (buffer[offset + 5] & 0xff) << 16 | (buffer[offset + 6] & 0xff) << 8 | (buffer[offset + 7] & 0xff);
}


/**
 * Converts two bytes of a byte array to a signed int.
 * <p>
 * The byte order is big-endian.
 * 
 * @param buffer
 * the byte array.
 * @param offset
 * the offset in the array.
 * @return the int value.
 */
+ (int) getShort:(Byte *)buffer offset:(int)offset {
  return buffer[offset] << 8 | (buffer[offset + 1] & 0xff);
}


/**
 * Private constructor to prevent instantiation from other classes.
 */
- (id) init {
  if (self = [super init]) {
	  [NSException raise:@"IllegalArgumentException" format:@"can't init the instance of Deserializer"];
  }
  return self;
}

@end
