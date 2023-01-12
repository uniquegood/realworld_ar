import Flutter
import AVFoundation

public class SwiftFlutterArImageTrackingF2nPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "flutter_ar_image_tracking_f2n", binaryMessenger: registrar.messenger())
      let instance = SwiftFlutterArImageTrackingF2nPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
      switch call.method {
      case "show":
          let controller = UIApplication.shared.delegate?.window??.rootViewController
          
          // let controller = call.window?.rootViewController
          // let controller = window?.rootViewController as! FlutterViewController
          let ar = ARTrackingViewController()
          ar.trackerImagePath = "https://realworld.blob.core.windows.net/misc-files/eFei3OV54JSBABDFePwRAw-ticket_AR.jpg"
          ar.trackerImageWidth = 0.25
          ar.overlayImagePath = "https://realworld.blob.core.windows.net/misc-files/x8W7_CU6w8TSlpyGv8RkPQ-ticket_OV.png"
          
          if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
              controller?.present(ar, animated: true, completion: nil)
          } else {
              AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] (granted: Bool) in
                  if granted {
                      DispatchQueue.main.async{
                          controller?.present(ar, animated: true, completion: nil)
                      }
                  } else {
//                      DispatchQueue.main.async {
//                          HGUtils.selectAlertView(self, withMessage: Localizations.Message.CameraAccessDenied, withOkButtonTitle: Localizations.Action.Confirm, {
//                              UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
//                          })
//                      }
                  }
              })
          }
          return
      default:
          result(FlutterMethodNotImplemented)
          return
      }
  }
}
