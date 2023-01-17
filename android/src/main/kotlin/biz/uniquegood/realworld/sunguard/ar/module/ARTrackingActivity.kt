package biz.uniquegood.realworld.sunguard.ar.module

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.util.Log
import android.util.Pair
import androidx.appcompat.app.AppCompatActivity
import biz.uniquegood.realworld.sunguard.ar.R
import biz.uniquegood.realworld.sunguard.ar.common.helpers.CameraPermissionHelper
import biz.uniquegood.realworld.sunguard.ar.common.helpers.DisplayRotationHelper
import biz.uniquegood.realworld.sunguard.ar.common.helpers.TrackingStateHelper
import biz.uniquegood.realworld.sunguard.ar.common.rendering.BackgroundRenderer
import biz.uniquegood.realworld.sunguard.ar.common.rendering.ImageRenderer
import com.google.ar.core.*
import com.google.ar.core.ArCoreApk.InstallStatus
import com.google.ar.core.exceptions.*
import java.io.IOException
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10


class ARTrackingActivity : AppCompatActivity(), GLSurfaceView.Renderer {
    companion object {
        val TAG: String = ARTrackingActivity::class.java.simpleName
    }

    private lateinit var surfaceView: GLSurfaceView
    private var session: Session? = null

    private val displayRotationHelper: DisplayRotationHelper by lazy { DisplayRotationHelper(this) }
    private val trackingStateHelper: TrackingStateHelper = TrackingStateHelper(this)

    private var installRequested = false
    private var shouldConfigureSession = false

    private val backgroundRenderer: BackgroundRenderer = BackgroundRenderer()

    private val augmentedImageMap: HashMap<Int, Pair<AugmentedImage, Anchor>> = HashMap()
    private val augmentedImageRenderer: AugmentedImageRenderer = AugmentedImageRenderer()
    private val arImage =
        ImageRenderer()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.ar_tracking_activity)
        surfaceView = findViewById(R.id.surface_view)
        // Set up renderer.
        surfaceView.preserveEGLContextOnPause = true
        surfaceView.setEGLContextClientVersion(2)
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0) // Alpha used for plane blending.
        surfaceView.setRenderer(this)
        surfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        surfaceView.setWillNotDraw(false)
    }

    override fun onResume() {
        super.onResume()

        if (session == null) {
            var exception: Exception? = null
            var message: String? = null
            try {
                when (ArCoreApk.getInstance().requestInstall(this, !installRequested)) {
                    InstallStatus.INSTALL_REQUESTED -> {
                        installRequested = true
                        return
                    }
                    InstallStatus.INSTALLED -> {}
                }

                // ARCore requires camera permissions to operate. If we did not yet obtain runtime
                // permission on Android M and above, now is a good time to ask the user for it.
                if (!CameraPermissionHelper.hasCameraPermission(this)) {
                    CameraPermissionHelper.requestCameraPermission(this)
                    return
                }
                session = Session( /* context = */this)
            } catch (e: UnavailableArcoreNotInstalledException) {
                message = "Please install ARCore"
                exception = e
            } catch (e: UnavailableUserDeclinedInstallationException) {
                message = "Please install ARCore"
                exception = e
            } catch (e: UnavailableApkTooOldException) {
                message = "Please update ARCore"
                exception = e
            } catch (e: UnavailableSdkTooOldException) {
                message = "Please update this app"
                exception = e
            } catch (e: Exception) {
                message = "This device does not support AR"
                exception = e
            }
            if (message != null) {
                Log.e(
                    TAG, "Exception creating session", exception
                )
                return
            }
            shouldConfigureSession = true
        }

        if (shouldConfigureSession) {
            configureSession()
            shouldConfigureSession = false
        }
        // Note that order matters - see the note in onPause(), the reverse applies here.
        try {
            session!!.resume()
        } catch (e: CameraNotAvailableException) {
            session = null
            return
        }
        surfaceView.onResume()
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

    private fun configureSession() {
        val config = Config(session)
        config.focusMode = Config.FocusMode.AUTO
        if (!setupAugmentedImageDatabase(config)) {
        }
        session!!.configure(config)
    }

    override fun onSurfaceCreated(gl: GL10, config: EGLConfig) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f)
        try {
            // Create the texture and pass it to ARCore session to be filled during update().
            backgroundRenderer.createOnGlThread( /*context=*/this)
            arImage.createOnGlThread(this, assets.open("models/overlay.png"))
            augmentedImageRenderer.createOnGlThread(this)
        } catch (e: IOException) {
            Log.e(TAG, "Failed to read an asset file", e);
        }
    }

    override fun onSurfaceChanged(gl: GL10, w: Int, h: Int) {
        displayRotationHelper.onSurfaceChanged(w, h)
        GLES20.glViewport(0, 0, w, h)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        if (session == null) {
            return;
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

            trackingStateHelper.updateKeepScreenOnFlag(camera.trackingState)

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

            drawAugmentedImages(camera, frame, proj, view, colorCorrectionRgba)
        } catch (t: Throwable) {
            Log.e(TAG, "Exception on OpenGL thread", t);
        }
    }


    private fun drawAugmentedImages(
        camera: Camera,
        frame: Frame,
        proj: FloatArray,
        view: FloatArray,
        colorCorrectionRgba: FloatArray
    ) {
        val updatedAugmentedImages = frame.getUpdatedTrackables(
            AugmentedImage::class.java
        )

        // Iterate to update augmentedImageMap, remove elements we cannot draw.
        for (augmentedImage in updatedAugmentedImages) {
            when (augmentedImage.trackingState) {
                TrackingState.PAUSED -> {
                    // When an image is in PAUSED state, but the camera is not PAUSED, it has been detected,
                    // but not yet tracked.
                    val text = String.format("Detected Image %d", augmentedImage.index)
                }
                TrackingState.TRACKING -> {
                    // Have to switch to UI Thread to update View.
                    // runOnUiThread { fitToScanView.setVisibility(View.GONE) }

                    // Create a new anchor for newly found images.
                    if (!augmentedImageMap.containsKey(augmentedImage.index)) {
                        val centerPoseAnchor =
                            augmentedImage.createAnchor(augmentedImage.centerPose)
                        augmentedImageMap[augmentedImage.index] =
                            Pair.create(augmentedImage, centerPoseAnchor)
                    }
                }
                TrackingState.STOPPED -> augmentedImageMap.remove(augmentedImage.index)
                else -> {}
            }
        }

        // Draw all images in augmentedImageMap
        for (pair in augmentedImageMap.values) {
            val augmentedImage = pair.first
            val centerAnchor = augmentedImageMap[augmentedImage.index]!!.second
            when (augmentedImage.trackingState) {
                TrackingState.TRACKING -> {
                    val transition = FloatArray(16)
                    augmentedImage.centerPose.compose(Pose.makeTranslation(0.0F, 0.0f, 0.0f))
                        .toMatrix(transition, 0)
                    arImage.updateModelMatrix(
                        transition,
                        augmentedImage.extentX,
                        augmentedImage.extentZ
                    )
                    arImage.draw(view, proj)
                }
                else -> {}
            }
        }
    }

    private fun setupAugmentedImageDatabase(config: Config): Boolean {
        // There are two ways to configure an AugmentedImageDatabase:
        // 1. Add Bitmap to DB directly
        // 2. Load a pre-built AugmentedImageDatabase
        // Option 2) has
        // * shorter setup time
        // * doesn't require images to be packaged in apk.
        val augmentedImageBitmap = loadAugmentedImageBitmap() ?: return false
        val augmentedImageDatabase = AugmentedImageDatabase(session)
        augmentedImageDatabase.addImage("image_name", augmentedImageBitmap)
        // If the physical size of the image is known, you can instead use:
        //     augmentedImageDatabase.addImage("image_name", augmentedImageBitmap, widthInMeters);
        // This will improve the initial detection speed. ARCore will still actively estimate the
        // physical size of the image as it is viewed from multiple viewpoints.
        config.augmentedImageDatabase = augmentedImageDatabase
        return true
    }

    private fun loadAugmentedImageBitmap(): Bitmap? {
        try {
            assets.open("models/target.jpg").use { `is` ->
                return BitmapFactory.decodeStream(
                    `is`
                )
            }
        } catch (e: IOException) {
            Log.e(
                TAG, "IO exception loading augmented image bitmap.", e
            )
        }
        return null
    }
}
