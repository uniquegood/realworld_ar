package biz.uniquegood.realworld.sunguard.ar.module

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import app.redwarp.gif.decoder.Gif
import app.redwarp.gif.decoder.Parser
import biz.uniquegood.realworld.sunguard.ar.common.extensions.bitmaps
import biz.uniquegood.realworld.sunguard.ar.common.rendering.ImageRenderer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URL

class ARTrackingOverlay {
    private val images: ArrayList<ImageRenderer> = arrayListOf()
    private val bitmaps: ArrayList<Bitmap> = arrayListOf()
    private var index = 0
    private var gif: Gif? = null
    private var animationStTime: Long = 0L
    private var initialize: Boolean = false

    fun init(overlayImageUrl: String, initializeCallback: () -> Unit) {
        CoroutineScope(Dispatchers.IO).launch {
            if (!initialize) {
                val stream = withContext(Dispatchers.IO) {
                    withContext(Dispatchers.IO) {
                        URL(overlayImageUrl).openConnection()
                    }.getInputStream()
                }
                if (overlayImageUrl.endsWith(".gif")) {
                    val gifDescriptor = withContext(Dispatchers.IO) {
                        Parser.parse(stream).getOrThrow()
                    }

                    gif = Gif(gifDescriptor)
                    gif!!.bitmaps().forEach {
                        bitmaps.add(it)
                        images.add(ImageRenderer())
                    }
                } else {
                    val bitmap = BitmapFactory.decodeStream(stream)
                    bitmaps.add(bitmap)
                    images.add(ImageRenderer())
                }
            }
            initialize = true
            initializeCallback()
        }
    }

    fun createOnGlThread(context: Context) {
        images.forEachIndexed { index, imageRenderer ->
            imageRenderer.createOnGlThread(context, bitmaps[index])
        }
        for (i in 0 until bitmaps.size) {
            bitmaps[i].recycle()
        }
    }

    fun updateModelMatrix(modelMatrix: FloatArray?, extendX: Float, extendY: Float) {
        images.forEach {
            it.updateModelMatrix(modelMatrix, extendX, extendY)
        }
    }

    fun draw(cameraView: FloatArray?, cameraPerspective: FloatArray?) {
        if (gif != null) {
            if (animationStTime == 0L) {
                animationStTime = System.currentTimeMillis()
            }
            val currentTime = System.currentTimeMillis() - animationStTime
            if (currentTime >= gif!!.getDelay(gif!!.currentIndex)) {
                animationStTime = System.currentTimeMillis()
                gif!!.advance()
            }
            index = gif!!.currentIndex
        }

        images[index].draw(cameraView, cameraPerspective)
    }
}