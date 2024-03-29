package biz.uniquegood.realworld.sunguard.ar.module

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.util.Log
import android.util.Pair
import android.view.View
import android.widget.Button
import android.widget.ImageView
import biz.uniquegood.realworld.sunguard.ar.R
import biz.uniquegood.realworld.sunguard.ar.RealWorldArPlugin
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showInsufficientImageQuality
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showInvalidImageFormat
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showMessage
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showNoInternet
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showNoResource
import biz.uniquegood.realworld.sunguard.ar.common.extensions.showNoSupportAR
import biz.uniquegood.realworld.sunguard.ar.common.helpers.CameraPermissionHelper
import biz.uniquegood.realworld.sunguard.ar.common.helpers.DisplayRotationHelper
import biz.uniquegood.realworld.sunguard.ar.common.helpers.TrackingStateHelper
import biz.uniquegood.realworld.sunguard.ar.common.rendering.BackgroundRenderer
import com.bumptech.glide.Glide
import com.google.ar.core.*
import com.google.ar.core.ArCoreApk.InstallStatus
import com.google.ar.core.exceptions.*
import com.tonyodev.fetch2core.isNetworkAvailable
import java.io.IOException
import java.net.URL
import java.util.Locale
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class ARTrackingActivity : Activity(), GLSurfaceView.Renderer {
    companion object {
        val TAG: String = ARTrackingActivity::class.java.simpleName
        const val AR_GUIDE: String = "guideImage"
        const val AR_AUGMENTED_IMAGE: String = "augmentedImage"
        const val AR_AUGMENTED_IMAGE_WIDTH: String = "augmentedImageWidth"
        const val AR_OVERLAY: String = "overlayImage"
        const val AR_BUTTON_LABEL: String = "buttonLabel"

        fun startActivity(
            context: Context,
            buttonLabel: String,
            guideImage: String?,
            augmentedImage: String,
            augmentedImageWidth: Double,
            overlayImage: String
        ) {
            context.startActivity(
                Intent(context, ARTrackingActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra(AR_GUIDE, guideImage)
                    putExtra(AR_AUGMENTED_IMAGE, augmentedImage)
                    putExtra(AR_AUGMENTED_IMAGE_WIDTH, augmentedImageWidth)
                    putExtra(AR_OVERLAY, overlayImage)
                    putExtra(AR_BUTTON_LABEL, buttonLabel)
                },
            )
        }
    }

    private lateinit var surfaceView: GLSurfaceView
    private var session: Session? = null

    private val displayRotationHelper: DisplayRotationHelper by lazy { DisplayRotationHelper(this) }
    private val trackingStateHelper: TrackingStateHelper = TrackingStateHelper(this)

    private var installRequested = false
    private var shouldConfigureSession = false

    private val backgroundRenderer: BackgroundRenderer = BackgroundRenderer()

    private val augmentedImageMap: HashMap<Int, Pair<AugmentedImage, Anchor>> = HashMap()
    private val trackingOverlay = ARTrackingOverlay()

    // 외부 이미지
    private lateinit var augmentedImageUrl: String
    private var augmentedImageWidth: Double = 0.0
    private lateinit var overlayImageUrl: String

    // 가이드 이미지
    private var guideImage: String = ""
    private lateinit var guideImageView: ImageView

    //
    private lateinit var buttonTracked: Button

    //
    private lateinit var buttonBack: Button

    override fun finish() {
        super.finish()
        overridePendingTransition(R.anim.no_change, R.anim.slide_down_out_easing)
    }

    fun isArCheckAndInternetValidate(): Boolean {
        return true
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.ar_tracking_activity)
//        supportActionBar?.hide()
//        supportActionBar?.setBackgroundDrawable(
//            ColorDrawable(ContextCompat.getColor(this, android.R.color.white))
//        )

        var flags: Int = window.decorView.systemUiVisibility // get current flag
        flags = flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR // add LIGHT_STATUS_BAR to flag
        window.decorView.systemUiVisibility = flags
        window.statusBarColor = Color.WHITE // optional

        augmentedImageUrl = intent.getStringExtra(AR_AUGMENTED_IMAGE) ?: ""
        augmentedImageWidth = intent.getDoubleExtra(AR_AUGMENTED_IMAGE_WIDTH, 0.0)
        overlayImageUrl = intent.getStringExtra(AR_OVERLAY) ?: ""

        window.statusBarColor = Color.WHITE
        surfaceView = findViewById(R.id.surface_view)
        // Set up renderer.
        surfaceView.preserveEGLContextOnPause = true
        surfaceView.setEGLContextClientVersion(2)
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0) // Alpha used for plane blending.
        surfaceView.setRenderer(this)
        surfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        surfaceView.setWillNotDraw(false)
        surfaceView.onPause()

        buttonBack = findViewById(R.id.button_finish)
        buttonBack.setOnClickListener {
            RealWorldArPlugin.lastResult?.success(false)
            setResult(Activity.RESULT_CANCELED)
            finish()
        }

        buttonTracked = findViewById(R.id.button_tracked)
        buttonTracked.text = intent.getStringExtra(AR_BUTTON_LABEL) ?: ""
        buttonTracked.isEnabled = false
        buttonTracked.setOnClickListener {
            RealWorldArPlugin.lastResult?.success(true)
            setResult(Activity.RESULT_OK)
            finish()
        }

        // 가이드 이미지
        guideImage = intent.getStringExtra(AR_GUIDE) ?: ""
        guideImageView = findViewById(R.id.image_view_guide)
        if (guideImage.isEmpty()) {
            guideImageView.visibility = View.GONE
        } else {
            Glide.with(this).load(guideImage).into(guideImageView)
        }
    }

    private fun checkDeviceARSupport(): Boolean {
        val openGlVersion =
            (getSystemService(ACTIVITY_SERVICE) as ActivityManager).deviceConfigurationInfo.glEsVersion
        return openGlVersion.toDouble() >= 3.0
    }

    override fun onBackPressed() {
        RealWorldArPlugin.lastResult?.success(false)
        setResult(Activity.RESULT_CANCELED)
        super.onBackPressed()
    }

    override fun onResume() {
        super.onResume()
        overridePendingTransition(R.anim.slide_up_in_easing, R.anim.slide_down_out_easing)

        if (!checkDeviceARSupport()) {
            showNoSupportAR()
            return
        }
        if (!isNetworkAvailable()) {
            showNoInternet()
            return
        }

        if (session == null) {
            var message: String? = null
            try {
                when (ArCoreApk.getInstance().requestInstall(this, !installRequested)) {
                    InstallStatus.INSTALL_REQUESTED -> {
                        installRequested = true
                        return
                    }

                    InstallStatus.INSTALLED -> {}
                }
                if (!CameraPermissionHelper.hasCameraPermission(this)) {
                    CameraPermissionHelper.requestCameraPermission(this)
                    return
                }
                session = Session(/* context = */ this)
            } catch (e: UnavailableArcoreNotInstalledException) {
                message = if (Locale.getDefault().language == "ko") {
                    "ARCore를 설치해주세요"
                } else {
                    "Please install ARCore"
                }
            } catch (e: UnavailableUserDeclinedInstallationException) {
                message = if (Locale.getDefault().language == "ko") {
                    "ARCore 설치를 거부하셨습니다"
                } else {
                    "Please install ARCore"
                }
            } catch (e: UnavailableApkTooOldException) {
                message = if (Locale.getDefault().language == "ko") {
                    "ARCore를 업데이트 해주세요"
                } else {
                    "Please update ARCore"
                }
            } catch (e: UnavailableSdkTooOldException) {
                message = if (Locale.getDefault().language == "ko") {
                    "앱을 업데이트 해주세요"
                } else {
                    "Please update this app"
                }
            } catch (e: Exception) {
                message = if (Locale.getDefault().language == "ko") {
                    "이 기기는 AR을 지원하지 않습니다"
                } else {
                    "This device does not support AR"
                }
            }
            if (message != null) {
                showMessage(message)
                return
            }
            shouldConfigureSession = true
        }

        if (shouldConfigureSession) {
            try {
                CoroutineScope(Dispatchers.Main).launch {
                    setupConfigureSession()
                    setupTrackingOverlay()
                    try {
                        session?.resume()
                        session?.pause()
                        session?.resume()
                    } catch (e: CameraNotAvailableException) {
                        session = null
                    }
                }
            } catch (ignore: Exception) {
            }
        }
        displayRotationHelper.onResume()
    }

    override fun onPause() {
        super.onPause()
        if (session != null) {
            displayRotationHelper.onPause()
            surfaceView.onPause()
            session!!.pause()
        }
    }

    override fun onDestroy() {
        if (session != null) {
            session!!.close()
            session = null
        }
        super.onDestroy()
    }

    /**
     * ARCore Session 설정
     * Augmented Image Database 설정
     * Augmented Image Database 설정이 실패하면 ARCore를 사용할 수 없는 기기로 판단
     */
    private suspend fun setupConfigureSession() {
        val config = Config(session)
        config.focusMode = Config.FocusMode.AUTO
        config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        val shouldInitializeConfig =
            withContext(Dispatchers.IO) { setupAugmentedImageDatabase(config) }
        if (shouldInitializeConfig) {
            session?.configure(config)
        }
    }

    /**
     * Augmented Tracking Overlay Image 설정
     */
    private fun setupTrackingOverlay() {
        try {
            if (overlayImageUrl.isNotEmpty()) trackingOverlay.init(overlayImageUrl) { surfaceView.onResume() }
        } catch (ignore: Exception) {

        }
    }

    override fun onSurfaceCreated(gl: GL10, config: EGLConfig) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f)
        try {
            // Create the texture and pass it to ARCore session to be filled during update().
            backgroundRenderer.createOnGlThread(/*context=*/ this)
            //
            trackingOverlay.createOnGlThread(this)
        } catch (e: IOException) {
            Log.e(TAG, "Failed to read an asset file", e)
        }
    }

    override fun onSurfaceChanged(gl: GL10, w: Int, h: Int) {
        displayRotationHelper.onSurfaceChanged(w, h)
        GLES20.glViewport(0, 0, w, h)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        if (session == null) {
            return
        }
        // Notify ARCore session that the view size changed so that the perspective matrix and
        // the video background can be properly adjusted.
        displayRotationHelper.updateSessionIfNeeded(session)
        try {
            session!!.setCameraTextureName(backgroundRenderer.textureId)
            // Obtain the current frame from ARSession. When the configuration is set to
            // UpdateMode.BLOCKING (it is by default), this will throttle the rendering to the
            // camera framerate.
            val frame = session!!.update()
            val camera = frame.camera

            // trackingStateHelper.updateKeepScreenOnFlag(camera.trackingState)

            // If frame is ready, render camera preview image to the GL surface
            backgroundRenderer.draw(frame)

            // Get projection matrix.
            val proj = FloatArray(16)
            camera.getProjectionMatrix(proj, 0, 0.1f, 100.0f)
            // Get camera matrix and draw.
            val view = FloatArray(16)
            camera.getViewMatrix(view, 0)
            // Compute lighting from average intensity of the image.
            val colorCorrectionRgba = FloatArray(4)
            frame.lightEstimate.getColorCorrection(colorCorrectionRgba, 0)

            drawAugmentedImages(frame, proj, view)
        } catch (t: Throwable) {
            Log.e(TAG, "Exception on OpenGL thread", t)
        }
    }

    private fun drawAugmentedImages(
        frame: Frame, proj: FloatArray, view: FloatArray
    ) {
        val updatedAugmentedImages = frame.getUpdatedTrackables(AugmentedImage::class.java)
        // Iterate to update augmentedImageMap, remove elements we cannot draw.
        for (augmentedImage in updatedAugmentedImages) {
            when (augmentedImage.trackingState) {
                TrackingState.PAUSED -> {}
                TrackingState.TRACKING -> {
                    if (!augmentedImageMap.containsKey(augmentedImage.index)) {
                        val centerPoseAnchor =
                            augmentedImage.createAnchor(augmentedImage.centerPose)
                        augmentedImageMap[augmentedImage.index] =
                            Pair.create(augmentedImage, centerPoseAnchor)
                    }
                }

                TrackingState.STOPPED -> {}
                else -> {}
            }
        }

        // Draw all images in augmentedImageMap
        for (pair in augmentedImageMap.values) {
            val augmentedImage = pair.first
            // val centerAnchor = augmentedImageMap[augmentedImage.index]!!.second
            when (augmentedImage.trackingState) {
                TrackingState.TRACKING -> {
                    val transition = FloatArray(16)
                    augmentedImage.centerPose.compose(Pose.makeTranslation(0.0F, 0.0f, 0.0f))
                        .toMatrix(transition, 0)
                    trackingOverlay.updateModelMatrix(
                        transition, augmentedImage.extentX, augmentedImage.extentZ
                    )
                    trackingOverlay.draw(view, proj)

                    runOnUiThread {
                        buttonTracked.isEnabled = true
                        buttonTracked.setTextColor(Color.parseColor("#ffffff"))
                        guideImageView.visibility = View.GONE
                    }
                }

                TrackingState.STOPPED -> {
                    buttonTracked.isEnabled = false
                }

                else -> {}
            }
        }
    }

    private fun setupAugmentedImageDatabase(config: Config): Boolean {
        val augmentedImageDatabase = AugmentedImageDatabase(session)
        val bitmap: Bitmap? = retry({ it is Exception }, 3, {
            val options = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
                inPremultiplied = true
            }
            BitmapFactory.decodeStream(
                URL(augmentedImageUrl).openConnection().getInputStream(), null, options
            )
        })

        var shouldInitializeConfig = true
        if (bitmap == null) {
            showNoResource()
            shouldInitializeConfig = false
        } else {
            val formatted: Bitmap = if (bitmap.config != Bitmap.Config.ARGB_8888) {
                bitmap.copy(Bitmap.Config.ARGB_8888, false)
            } else {
                bitmap
            }
            try {
                if (augmentedImageWidth > 0.0) {
                    augmentedImageDatabase.addImage(
                        "image_name", bitmap, augmentedImageWidth.toFloat()
                    )
                } else {
                    augmentedImageDatabase.addImage("image_name", bitmap)
                }
                config.augmentedImageDatabase = augmentedImageDatabase
            } catch (e: IllegalArgumentException) {
                showInvalidImageFormat()
                shouldInitializeConfig = false
            } catch (e: ImageInsufficientQualityException) {
                showInsufficientImageQuality()
                shouldInitializeConfig = false
            }
            try {
                if (!bitmap.isRecycled)
                    bitmap.recycle()
                if (!formatted.isRecycled)
                    formatted.recycle()
            } catch (_: Exception) {
            }
        }
        return shouldInitializeConfig
    }
}

inline fun <T> retry(
    predicate: (cause: Throwable) -> Boolean = { true }, retries: Int = 1, call: () -> T
): T? {
    for (i in 0..retries) {
        return try {
            call()
        } catch (e: Exception) {
            if (predicate(e) && i < retries) {
                continue
            } else {
                null
            }
        }
    }
    return null
}
