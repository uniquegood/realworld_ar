#import "FlutterArImageTrackingF2nPlugin.h"
#if __has_include(<flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n-Swift.h>)
#import <flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_ar_image_tracking_f2n-Swift.h"
#endif

@implementation FlutterArImageTrackingF2nPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterArImageTrackingF2nPlugin registerWithRegistrar:registrar];
}
@end
