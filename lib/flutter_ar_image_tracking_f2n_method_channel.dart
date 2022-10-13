import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ar_image_tracking_f2n_platform_interface.dart';

/// An implementation of [FlutterArImageTrackingF2nPlatform] that uses method channels.
class MethodChannelFlutterArImageTrackingF2n
    extends FlutterArImageTrackingF2nPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ar_image_tracking_f2n');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> show() async {
    await methodChannel.invokeMethod<void>('show');
  }
}
