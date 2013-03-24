//#import "IOUtils.h"
//
//Logger * const LOG = [Logger getLogger:[[IOUtils class] name]];
//
//@implementation IOUtils
//
//
///**
// * Invokes the {@link Closeable#close()} method on the given object. If an {@link IOException} occurs during the
// * method call, it will be caught and logged on level {@link Level#WARNING}.
// * 
// * @param closeable
// * the data source which should be closed (may be null).
// */
//+ (void) closeQuietly:(Closeable *)closeable {
//
//  @try {
//    if (closeable != nil) {
//      [closeable close];
//    }
//  }
//  @catch (IOException * e) {
//    [LOG log:Level.WARNING param1:nil param2:e];
//  }
//}
//
//- (id) init {
//  if (self = [super init]) {
//    @throw [[[IllegalStateException alloc] init] autorelease];
//  }
//  return self;
//}
//
//@end
