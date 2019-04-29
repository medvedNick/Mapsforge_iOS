#import "ReadBuffer.h"
#import "Deserializer.h"

//NSString * const CHARSET_UTF8 = @"UTF-8";

/**
 * Maximum buffer size which is supported by this implementation.
 */
int const MAXIMUM_BUFFER_SIZE = 2500000;

@implementation ReadBuffer

- (id) initWithInputFile:(NSData *)_inputFile {
  if (self = [super init]) {
      inputFile = _inputFile;
  }
  return self;
}


/**
 * Returns one signed byte from the read buffer.
 * 
 * @return the byte value.
 */
- (Byte) readByte {
  NSRange range = NSMakeRange(bufferPosition, 1);
  bufferPosition++;
  Byte byte;
  [bufferData getBytes:&byte range:range];
  return byte;
}


/**
 * Reads the given amount of bytes from the file into the read buffer and resets the internal buffer position. If
 * the capacity of the read buffer is too small, a larger one is created automatically.
 * 
 * @param length
 * the amount of bytes to read from the file.
 * @return true if the whole data was read successfully, false otherwise.
 * @throws IOException
 * if an error occurs while reading the file.
 */
- (BOOL) readFromFile:(long)length {
  if (bufferData == nil || bufferData.length-bufferPosition < length) {
    if (length > MAXIMUM_BUFFER_SIZE) {
		NSLog(@"invalid read length:%ld", length);
      return NO;
    }
    bufferData = [[NSData alloc] init];
  }
  globalBufferPosition += bufferPosition;
//  NSData *d = [NSData dataWithContentsOfFile:inputFile options:NSDataReadingMappedIfSafe error:nil];
//  bufferData = [d subdataWithRange:NSMakeRange(globalBufferPosition, length)];
//    if (bufferData == nil)
//    {
//        NSLog(@"WTF?!");
//    }
//  [bufferData release];
    bufferData = [inputFile subdataWithRange:NSMakeRange(globalBufferPosition, length)];// retain];
  buffer = (Byte*)bufferData.bytes;
  bufferPosition = 0;
  return YES;//[inputFile read:bufferData param1:0 param2:length] == length;
}

- (void) seekTo:(long)offset
{
    globalBufferPosition = offset;
    bufferPosition = 0;
}


/**
 * Converts four bytes from the read buffer to a signed int.
 * <p>
 * The byte order is big-endian.
 * 
 * @return the int value.
 */
- (int) readInt {
  bufferPosition += 4;
  return [Deserializer getInt:buffer offset:bufferPosition - 4];
}


/**
 * Converts eight bytes from the read buffer to a signed long.
 * <p>
 * The byte order is big-endian.
 * 
 * @return the long value.
 */
- (long long) readLong {
  bufferPosition += 8;
  return [Deserializer getLong:buffer offset:bufferPosition - 8];
}


/**
 * Converts two bytes from the read buffer to a signed int.
 * <p>
 * The byte order is big-endian.
 * 
 * @return the int value.
 */
- (int) readShort {
  bufferPosition += 2;
  return [Deserializer getShort:buffer offset:bufferPosition - 2];
}


/**
 * Converts a variable amount of bytes from the read buffer to a signed int.
 * <p>
 * The first bit is for continuation info, the other six (last byte) or seven (all other bytes) bits are for data.
 * The second bit in the last byte indicates the sign of the number.
 * 
 * @return the int value.
 */
- (int) readSignedInt {
  int variableByteDecode = 0;
  char variableByteShift = 0;

   while ((buffer[bufferPosition] & 0x80) != 0x0) {
    variableByteDecode |= (buffer[bufferPosition++] & 0x7f) << variableByteShift;
    variableByteShift += 7;
  }

  if ((buffer[bufferPosition] & 0x40) != 0x0) {
    return -(variableByteDecode | ((buffer[bufferPosition++] & 0x3f) << variableByteShift));
  }
  return variableByteDecode | ((buffer[bufferPosition++] & 0x3f) << variableByteShift);
}


- (int) readLongerSignedInt {
    int variableByteDecode = 0;
    char variableByteShift = 0;
    
    while ((buffer[bufferPosition] & 0x80) != 0x0) {
        variableByteDecode |= (buffer[bufferPosition++] & 0x7f) << variableByteShift;
        variableByteShift += 7;
    }
    
    if ((buffer[bufferPosition] & 0x40) != 0x0) {
        return -(variableByteDecode | ((buffer[bufferPosition++] & 0x3f) << variableByteShift));
    }
    return variableByteDecode | ((buffer[bufferPosition++] & 0x3f) << variableByteShift);
}

/**
 * Converts a variable amount of bytes from the read buffer to an unsigned int.
 * <p>
 * The first bit is for continuation info, the other seven bits are for data.
 * 
 * @return the int value.
 */
- (uint) readUnsignedInt {
  int variableByteDecode = 0;
  char variableByteShift = 0;

  while ((buffer[bufferPosition] & 0x80) != 0) {
    variableByteDecode |= (buffer[bufferPosition++] & 0x7f) << variableByteShift;
    variableByteShift += 7;
  }

  return variableByteDecode | (buffer[bufferPosition++] << variableByteShift);
}


/**
 * Decodes a variable amount of bytes from the read buffer to a string.
 * 
 * @return the UTF-8 decoded string (may be null).
 */
- (NSString *) readUTF8EncodedString {
  return [self readUTF8EncodedString:[self readUnsignedInt]];
}


/**
 * Decodes the given amount of bytes from the read buffer to a string.
 * 
 * @param stringLength
 * the length of the string in bytes.
 * @return the UTF-8 decoded string (may be null).
 */
- (NSString *) readUTF8EncodedString:(long)stringLength {
  if (stringLength > 0 && bufferPosition + stringLength <= bufferData.length) {
    bufferPosition += stringLength;
    @try {
      return [[NSString alloc] initWithBytes:buffer+bufferPosition-stringLength length:stringLength encoding:NSUTF8StringEncoding];
      //return [[[NSString alloc] init:bufferData param1:bufferPosition - stringLength param2:stringLength param3:CHARSET_UTF8] autorelease];
    }
    @catch (NSException * e) {
      NSLog(@"Unsupported encoding exception in -ReadUTF8EncodedString: in ReadBuffer.m: %@, %@", e.name, e.reason);
      //@throw [[[IllegalStateException alloc] init:e] autorelease];
    }
  }
  NSLog(@"invalid string length: %l", stringLength);
//  [LOG warning:[@"invalid string length: " stringByAppendingString:stringLength]];
  return nil;
}


/**
 * @return the current buffer position.
 */
- (int) getBufferPosition {
  return bufferPosition;
}


/**
 * @return the current size of the read buffer.
 */
- (int) getBufferSize {
  return bufferData.length;
}


/**
 * Sets the buffer position to the given offset.
 * 
 * @param bufferPosition
 * the buffer position.
 */
- (void) setBufferPosition:(int)_bufferPosition {
  bufferPosition = _bufferPosition;
}


/**
 * Skips the given number of bytes in the read buffer.
 * 
 * @param bytes
 * the number of bytes to skip.
 */
- (void) skipBytes:(int)bytes {
  bufferPosition += bytes;
}

//- (void) dealloc {
//  [bufferData release];
////  [inputFile release];
//  [super dealloc];
//}

@end
