package biz.uniquegood.realworld.sunguard.ar

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import androidx.core.content.ContextCompat

private const val MIN_OPENGL_VERSION = 3.0

fun Context.isSupportAR(): Boolean {
    val service = ContextCompat.getSystemService(this, ActivityManager::class.java) ?: return false
    val opengl = service.deviceConfigurationInfo?.glEsVersion ?: return false
    return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && opengl.toDouble() >= MIN_OPENGL_VERSION
}