package biz.uniquegood.realworld.sunguard.ar

import android.content.Context
import biz.uniquegood.realworld.sunguard.ar.module.ARTrackingActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** RealworldArPlugin */
class RealWorldArPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    companion object {
        var lastResult: MethodChannel.Result? = null
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "realworld_ar")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "recognition") {
            lastResult = result

            val arguments = call.arguments as Map<*, *>
            val augmentedImage = arguments["augmentedImage"].toString()
            val augmentedImageWidth = arguments.getOrDefault("augmentedImageWidth", 0.0) as Double
            val overlayImage = arguments["overlayImage"].toString()
            val guideImage = arguments["guideImage"]?.toString()
            val buttonLabel = arguments["buttonLabel"]?.toString() ?: ""

            ARTrackingActivity.startActivity(
                context = context,
                buttonLabel = buttonLabel,
                guideImage = guideImage,
                augmentedImage = augmentedImage,
                augmentedImageWidth = augmentedImageWidth,
                overlayImage = overlayImage
            )
        } else {
            lastResult?.success(false)
            lastResult = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
