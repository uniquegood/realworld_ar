import 'flutter_ar_image_tracking_f2n_platform_interface.dart';

class FlutterArImageTrackingF2n {
  Future<void> show() async {
    await FlutterArImageTrackingF2nPlatform.instance.show();
  }

  Future<String?> getPlatformVersion() {
    return FlutterArImageTrackingF2nPlatform.instance.getPlatformVersion();
  }
}
