import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n.dart';
import 'package:flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n_platform_interface.dart';
import 'package:flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterArImageTrackingF2nPlatform
    with MockPlatformInterfaceMixin
    implements FlutterArImageTrackingF2nPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterArImageTrackingF2nPlatform initialPlatform = FlutterArImageTrackingF2nPlatform.instance;

  test('$MethodChannelFlutterArImageTrackingF2n is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterArImageTrackingF2n>());
  });

  test('getPlatformVersion', () async {
    FlutterArImageTrackingF2n flutterArImageTrackingF2nPlugin = FlutterArImageTrackingF2n();
    MockFlutterArImageTrackingF2nPlatform fakePlatform = MockFlutterArImageTrackingF2nPlatform();
    FlutterArImageTrackingF2nPlatform.instance = fakePlatform;

    expect(await flutterArImageTrackingF2nPlugin.getPlatformVersion(), '42');
  });
}
