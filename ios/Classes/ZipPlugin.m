#import "ZipPlugin.h"
#if __has_include(<zip_plugin/zip_plugin-Swift.h>)
#import <zip_plugin/zip_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zip_plugin-Swift.h"
#endif

@implementation ZipPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZipPlugin registerWithRegistrar:registrar];
}
@end
