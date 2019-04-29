
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
- (BOOL) readFromFile:(long)length;
- (void) seekTo:(long)offset;
- (int) readInt;
- (long long) readLong;
- (int) readLongerSignedInt;
- (int) readShort;
- (int) readSignedInt;
- (uint) readUnsignedInt;
- (NSString *) readUTF8EncodedString;
- (NSString *) readUTF8EncodedString:(long)stringLength;
- (int) getBufferPosition;
- (int) getBufferSize;
- (void) setBufferPosition:(int)bufferPosition;
- (void) skipBytes:(int)bytes;
@end
