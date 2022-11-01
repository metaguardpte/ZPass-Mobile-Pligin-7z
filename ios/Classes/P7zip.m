#import "P7zip.h"
#if __has_include(<p7zip/p7zip-Swift.h>)
#import <p7zip/p7zip-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "p7zip-Swift.h"
#endif

@implementation P7zip
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftP7zip registerWithRegistrar:registrar];
}
@end
