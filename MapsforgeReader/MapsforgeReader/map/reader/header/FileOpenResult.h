#import "MapDatabase.h"
#import "FileOpenResult.h"

/**
 * A FileOpenResult is a simple DTO which is returned by {@link MapDatabase#openFile(File)}.
 */


/**
 * Singleton for a FileOpenResult instance with {@code success=true}.
 */


@interface FileOpenResult : NSObject {
  NSString * errorMessage;
  BOOL success;
}

@property(nonatomic, retain, readonly) NSString * errorMessage;
@property(nonatomic, readonly) BOOL success;
- (id) initWithErrorMessage:(NSString *)errorMessage;
- (NSString *) description;
+ (id) SUCCESS;
@end

//extern FileOpenResult * const SUCCESS;
