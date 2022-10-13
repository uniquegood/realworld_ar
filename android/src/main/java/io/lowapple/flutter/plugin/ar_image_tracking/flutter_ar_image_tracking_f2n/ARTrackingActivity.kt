package io.lowapple.flutter.plugin.ar_image_tracking.flutter_ar_image_tracking_f2n

import android.annotation.TargetApi
import android.os.Build
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.google.ar.core.AugmentedImage
import com.google.ar.core.Frame
import com.google.ar.sceneform.FrameTime
import com.google.ar.sceneform.Node


class ARTrackingActivity : AppCompatActivity() {
    private lateinit var augmentedImageFragment: ARAugmentedFragment
    private val augmentedImageMap: HashMap<AugmentedImage, Node> = hashMapOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!isSupportAR()) {
            throw RuntimeException("Not support AR")
        } else {
            setContentView(R.layout.ar_tracking_activity)
            augmentedImageFragment =
                supportFragmentManager.findFragmentById(R.id.fragment_augmented) as ARAugmentedFragment
            augmentedImageFragment.setAugmentedImageUrl(
                "https://realworld.blob.core.windows.net/misc-files/eFei3OV54JSBABDFePwRAw-ticket_AR.jpg",
                "0.25"
            )
            augmentedImageFragment.arSceneView.scene.addOnUpdateListener(this::onUpdateFrame);

        }
    }

    @TargetApi(Build.VERSION_CODES.N)
    private fun onUpdateFrame(frameTime: FrameTime) {
        val frame: Frame = augmentedImageFragment.arSceneView.arFrame ?: return
        val updatedAugmentedImages = frame.getUpdatedTrackables(AugmentedImage::class.java)
        for (img in updatedAugmentedImages) {
            when (img.trackingMethod) {
                AugmentedImage.TrackingMethod.FULL_TRACKING -> {
                    if (!augmentedImageMap.containsKey(img)) {
                        val overlayNode =
                            AROverlayImage(
                                this,
                                "https://realworld.blob.core.windows.net/misc-files/x8W7_CU6w8TSlpyGv8RkPQ-ticket_OV.png"
                            )
                        overlayNode.setImage(img)
                        augmentedImageFragment.arSceneView.scene.addChild(overlayNode)
                        augmentedImageMap[img] = overlayNode
                    }
                }
                else -> {

                }
            }
        }
    }
}