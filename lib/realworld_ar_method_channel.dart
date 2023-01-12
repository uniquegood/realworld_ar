import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'realworld_ar_platform_interface.dart';

/// An implementation of [RealworldArPlatform] that uses method channels.
class MethodChannelRealworldAr extends RealworldArPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('realworld_ar');

  @override
  Future<void> show() async {
    await methodChannel.invokeMethod<void>('show');
  }
}
