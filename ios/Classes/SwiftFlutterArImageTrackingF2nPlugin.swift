import Flutter
import UIKit

public class SwiftFlutterArImageTrackingF2nPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_ar_image_tracking_f2n", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterArImageTrackingF2nPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
