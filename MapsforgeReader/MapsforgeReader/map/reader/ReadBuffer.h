
/**
 * Reads from a {@link RandomAccessFile} into a buffer and decodes the data.
 */

@interface ReadBuffer : NSObject {
  NSData * bufferData;
  Byte *buffer;
  int bufferPosition;
  int globalBufferPosition;
  NSData * inputFile;
}

- (id) initWithInputFile:(NSData *)inputFile;
- (Byte) readByte;
- (BOOL) readFromFile:(int)length;
- (void) seekTo:(long long)offset;
- (int) readInt;
- (long long) readLong;
- (int) readShort;
- (int) readSignedInt;
- (uint) readUnsignedInt;
- (NSString *) readUTF8EncodedString;
- (NSString *) readUTF8EncodedString:(int)stringLength;
- (int) getBufferPosition;
- (int) getBufferSize;
- (void) setBufferPosition:(int)bufferPosition;
- (void) skipBytes:(int)bytes;
@end
