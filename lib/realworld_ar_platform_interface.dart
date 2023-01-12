import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'realworld_ar_method_channel.dart';

abstract class RealworldArPlatform extends PlatformInterface {
  /// Constructs a RealworldArPlatform.
  RealworldArPlatform() : super(token: _token);

  static final Object _token = Object();

  static RealworldArPlatform _instance = MethodChannelRealworldAr();

  /// The default instance of [RealworldArPlatform] to use.
  ///
  /// Defaults to [MethodChannelRealworldAr].
  static RealworldArPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RealworldArPlatform] when
  /// they register themselves.
  static set instance(RealworldArPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> show() {
    throw UnimplementedError('show() has not been implemented.');
  }
}
