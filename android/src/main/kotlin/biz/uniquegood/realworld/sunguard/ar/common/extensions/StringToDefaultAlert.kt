package biz.uniquegood.realworld.sunguard.ar.common.extensions

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import biz.uniquegood.realworld.sunguard.ar.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

fun Activity.showNoSupportAR() {
    val message = getString(R.string.label_device_does_not_support_ar)
    message.showAlertDefault(this)
}

fun Activity.showNoInternet() {
    val message = getString(R.string.label_internet_failure)
    message.showAlertDefault(this)
}

fun Activity.showNoResource() {
    val message = getString(R.string.label_download_failure)
    message.showAlertDefault(this)
}

fun Activity.showInvalidImageFormat() {
    val message = getString(R.string.label_invalid_image_format)
    message.showAlertDefault(this)
}

fun Activity.showInsufficientImageQuality() {
    val message = getString(R.string.label_insufficient_image_quality)
    message.showAlertDefault(this)
}

fun Activity.showMessage(message: String) {
    message.showAlertDefault(this)
}

fun String.showAlertDefault(activity: Activity) {
    CoroutineScope(Dispatchers.Main).launch {
        AlertDialog.Builder(activity)
            .setTitle(R.string.alert_title)
            .setMessage(this@showAlertDefault)
            .setPositiveButton(R.string.label_ok) { _: DialogInterface?, _: Int ->
                activity.finish()
            }.create().show()
    }
}