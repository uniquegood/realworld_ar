package biz.uniquegood.realworld.sunguard.ar.common.helpers

import android.content.Context
import com.tonyodev.fetch2.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class TextureManager {
    companion object {
        suspend fun fetch(context: Context, url: String): String {
            return suspendCoroutine {
                val fetchConfiguration: FetchConfiguration =
                    FetchConfiguration.Builder(context).setDownloadConcurrentLimit(3).build()
                val downloader = Fetch.Impl.getInstance(fetchConfiguration)
                val path = url.split("/").last()
                val cacheDir = context.cacheDir.absolutePath + "/$path"
                val req = Request(url, cacheDir)
                req.priority = Priority.HIGH
                req.networkType = NetworkType.ALL
                downloader.enqueue(req, { _ ->
                    it.resume(value = cacheDir)
                }) { error ->
                    throw error.throwable!!
                }
            }
        }
    }
}