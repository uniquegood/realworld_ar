package biz.uniquegood.realworld.sunguard.ar.common.extensions

import android.graphics.Bitmap
import app.redwarp.gif.decoder.Gif
import kotlin.math.sign

fun Gif.bitmaps(): List<Bitmap> {
    val bitmaps = arrayListOf<Bitmap>()
    for (i in 0 until this.frameCount) {
        val pixels = IntArray(dimension.size)
        val (width, height) = dimension
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        getFrame(i, pixels)
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height)
        bitmaps.add(bitmap)
    }
    return bitmaps
}