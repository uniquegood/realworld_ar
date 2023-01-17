package biz.uniquegood.realworld.sunguard.ar.common.extensions

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.resource.gif.GifDrawable
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.target.ImageViewTarget
import com.bumptech.glide.request.transition.Transition

fun String.downloadAndBitmap(context: Context, load: (Bitmap) -> Unit) {
    Glide.with(context).asBitmap().load(this)
        .apply(RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
        .encodeFormat(Bitmap.CompressFormat.PNG)
        .into(object : CustomTarget<Bitmap?>() {
            override fun onLoadCleared(placeholder: Drawable?) {}

            override fun onResourceReady(
                resource: Bitmap, transition: Transition<in Bitmap?>?
            ) {
                load(resource)
            }
        })
}

fun String.downloadAndGif(context: Context, load: (Bitmap) -> Unit) {
    Glide.with(context).asGif().load(this)
        .apply(RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
        .into(object : ImageViewTarget<GifDrawable>(null) {
            override fun setResource(resource: GifDrawable?) {

                if(resource == null)
                    return;
                resource.apply {
                    this.buffer
                }
            }
        })
}