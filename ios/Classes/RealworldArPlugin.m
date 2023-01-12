#import "RealworldArPlugin.h"
#if __has_include(<realworld_ar/realworld_ar-Swift.h>)
#import <realworld_ar/realworld_ar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "realworld_ar-Swift.h"
#endif

@implementation RealworldArPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRealworldArPlugin registerWithRegistrar:registrar];
}
@end
