import Flutter
import UIKit

public class SwiftRealworldArPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "realworld_ar", binaryMessenger: registrar.messenger())
    let instance = SwiftRealworldArPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    result("iOS " + UIDevice.current.systemVersion)
      
      switch call.method {
      case "recognition":
          print("call method recognition")
          if let argument = call.arguments as? [String: Any] {
              if let augmentedImage: String = argument["augmentedImage"] as? String, let overlayImage: String = argument["overlayImage"] as? String {
                  let buttonLabel: String? = argument["buttonLabel"] as? String
                  let guideImage: String? = argument["guideImage"]as? String
                  let augmentedImageWidth: Double? = argument["augmentedImageWidth"]as? Double
                  
                  if let rootVC = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController {
                      let ARView = QuestARImageRecognitionViewController(buttonLabel: buttonLabel, guideImageString: guideImage, augmentedImageString: augmentedImage, augmentedImageWidth: augmentedImageWidth, overlayImageString: overlayImage) { actionResult in
                          result(actionResult)
                      }
                      rootVC.present(ARView, animated: true)
                  }
              } else {
                  result(false)
              }
          }
          break
      default:
          result(false)
          break
      }
  }
}
