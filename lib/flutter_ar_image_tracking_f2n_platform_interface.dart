import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ar_image_tracking_f2n_method_channel.dart';

abstract class FlutterArImageTrackingF2nPlatform extends PlatformInterface {
  /// Anchors Image
  String? _anchorsImagePath;

  /// Overlap Image
  String? _overlapImagePath;

  FlutterArImageTrackingF2nPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterArImageTrackingF2nPlatform _instance =
      MethodChannelFlutterArImageTrackingF2n();
  static FlutterArImageTrackingF2nPlatform get instance => _instance;
  static set instance(FlutterArImageTrackingF2nPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> show() async {
    throw UnimplementedError('show() has not been implemented.');
  }
}
