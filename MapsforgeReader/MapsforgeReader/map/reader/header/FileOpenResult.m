#import "FileOpenResult.h"


/**
 * Singleton for a FileOpenResult instance with {@code success=true}.
 */
//FileOpenResult * const SUCCESS = nil;//[[[FileOpenResult alloc] init] autorelease];

@implementation FileOpenResult

@synthesize errorMessage;
@synthesize success;

+ (id) SUCCESS
{
    return [[FileOpenResult alloc] init];// autorelease];
}

/**
 * @param errorMessage
 * a textual message describing the error, must not be null.
 */
- (id) initWithErrorMessage:(NSString *)_errorMessage {
  if (self = [super init]) {
    if (_errorMessage == nil) {
      [NSException raise:@"IllegalArgumentException" format:@"error message must not be null"];
    }
    success = NO;
    errorMessage = _errorMessage;
  }
  return self;
}

- (id) init {
  if (self = [super init]) {
    success = YES;
    errorMessage = nil;
  }
  return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"FileOpenResult [success=%d, errorMessage=%@]", success, errorMessage];
}

//- (void) dealloc {
//  [errorMessage release];
//  [super dealloc];
//}

@end
