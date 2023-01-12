import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'realworld_ar_method_channel.dart';

abstract class RealWorldArPlatform extends PlatformInterface {
  /// Constructs a RealworldArPlatform.
  RealWorldArPlatform() : super(token: _token);

  static final Object _token = Object();

  static RealWorldArPlatform _instance = MethodChannelRealworldAr();

  /// The default instance of [RealWorldArPlatform] to use.
  ///
  /// Defaults to [MethodChannelRealworldAr].
  static RealWorldArPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RealWorldArPlatform] when
  /// they register themselves.
  static set instance(RealWorldArPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> show() {
    throw UnimplementedError('show() has not been implemented.');
  }
}
