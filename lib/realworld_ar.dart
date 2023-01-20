// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'realworld_ar_platform_interface.dart';

class RealWorldAr {
  Future<bool> recognition({
    required String? buttonLabel,
    required String? guideImage,
    required String augmentedImage,
    required double? augmentedImageWidth,
    required String overlayImage,
  }) async {
    return await RealWorldArPlatform.instance.recognition(
      buttonLabel: buttonLabel,
      guideImage: guideImage,
      augmentedImage: augmentedImage,
      augmentedImageWidth: augmentedImageWidth ?? 0.0,
      overlayImage: overlayImage,
    );
  }
}
