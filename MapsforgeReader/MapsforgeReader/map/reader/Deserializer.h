
/**
 * This utility class contains methods to convert byte arrays to numbers.
 */

@interface Deserializer : NSObject {
}

+ (long long) getFiveBytesLong:(Byte *)buffer offset:(long)offset;
+ (int) getInt:(Byte *)buffer offset:(int)offset;
+ (long long) getLong:(Byte *)buffer offset:(int)offset;
+ (int) getShort:(Byte *)buffer offset:(int)offset;
@end
