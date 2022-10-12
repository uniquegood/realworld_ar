import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ar_image_tracking_f2n/flutter_ar_image_tracking_f2n_method_channel.dart';

void main() {
  MethodChannelFlutterArImageTrackingF2n platform = MethodChannelFlutterArImageTrackingF2n();
  const MethodChannel channel = MethodChannel('flutter_ar_image_tracking_f2n');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
