#import "SubFileParameterBuilder.h"

@implementation SubFileParameterBuilder

- (SubFileParameter *) build {
  return [[SubFileParameter alloc] initWithSubFileParameterBuilder:self];// autorelease];
}

//- (void) dealloc {
////  [boundingBox release];
//  [super dealloc];
//}

@end
