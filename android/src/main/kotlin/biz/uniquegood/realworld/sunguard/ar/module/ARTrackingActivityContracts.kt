package biz.uniquegood.realworld.sunguard.ar.module

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContract

class ARTrackingActivityContracts : ActivityResultContract<Map<*, *>, Boolean>() {

    override fun createIntent(context: Context, input: Map<*, *>): Intent {
        val augmentedImage = input["augmentedImage"].toString()
        val augmentedImageWidth = input.getOrDefault("augmentedImageWidth", 0.0) as Double
        val overlayImage = input["overlayImage"].toString()
        val guideImage = input["guideImage"]?.toString()
        val buttonLabel = input["buttonLabel"]?.toString() ?: ""

        return Intent(context, ARTrackingActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(ARTrackingActivity.AR_GUIDE, guideImage)
            putExtra(ARTrackingActivity.AR_AUGMENTED_IMAGE, augmentedImage)
            putExtra(ARTrackingActivity.AR_AUGMENTED_IMAGE_WIDTH, augmentedImageWidth)
            putExtra(ARTrackingActivity.AR_OVERLAY, overlayImage)
            putExtra(ARTrackingActivity.AR_BUTTON_LABEL, buttonLabel)
        }
    }

    override fun parseResult(resultCode: Int, intent: Intent?): Boolean {
        return resultCode == Activity.RESULT_OK
    }
}