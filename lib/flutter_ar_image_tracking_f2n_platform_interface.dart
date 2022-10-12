import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ar_image_tracking_f2n_method_channel.dart';

abstract class FlutterArImageTrackingF2nPlatform extends PlatformInterface {
  /// Constructs a FlutterArImageTrackingF2nPlatform.
  FlutterArImageTrackingF2nPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterArImageTrackingF2nPlatform _instance = MethodChannelFlutterArImageTrackingF2n();

  /// The default instance of [FlutterArImageTrackingF2nPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterArImageTrackingF2n].
  static FlutterArImageTrackingF2nPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterArImageTrackingF2nPlatform] when
  /// they register themselves.
  static set instance(FlutterArImageTrackingF2nPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
