import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'realworld_ar_platform_interface.dart';

/// An implementation of [RealWorldArPlatform] that uses method channels.
class MethodChannelRealworldAr extends RealWorldArPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('realworld_ar');

  @override
  Future<bool> recognition({
    required String? buttonLabel,
    required String? guideImage,
    required String augmentedImage,
    required double? augmentedImageWidth,
    required String overlayImage,
  }) async {
    final res = await methodChannel.invokeMethod<bool>('recognition', {
      'buttonLabel': buttonLabel,
      'guideImage': guideImage,
      'augmentedImage': augmentedImage,
      'augmentedImageWidth': augmentedImageWidth,
      'overlayImage': overlayImage,
    });
    return res ?? false;
  }
}
