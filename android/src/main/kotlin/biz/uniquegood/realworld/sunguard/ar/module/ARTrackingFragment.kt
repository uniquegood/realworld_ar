//package biz.uniquegood.realworld.sunguard.ar.module
//
//import android.graphics.Bitmap
//import android.graphics.drawable.Drawable
//import android.os.Bundle
//import android.view.LayoutInflater
//import android.view.View
//import android.view.ViewGroup
//import com.bumptech.glide.Glide
//import com.bumptech.glide.load.DecodeFormat
//import com.bumptech.glide.request.RequestOptions
//import com.bumptech.glide.request.target.CustomTarget
//import com.bumptech.glide.request.transition.Transition
//import com.google.ar.core.AugmentedImageDatabase
//import com.google.ar.core.Config
//import com.google.ar.core.Session
//import com.google.ar.sceneform.ux.ArFragment
//
//
//class ARAugmentedFragment : ArFragment() {
//    private val DEFAULT_IMAGE_NAME = "default"
//    private var augmentedImageUrl = ""
//    private var augmentedImageWidth = 0.0f
//    private var augmentedImageDatabase: AugmentedImageDatabase? = null
//
//
//    override fun onCreateView(
//        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
//    ): View? {
//        val view = super.onCreateView(inflater, container, savedInstanceState)
//
//        // Hide default plane discovery controller
//        planeDiscoveryController.hide()
//        planeDiscoveryController.setInstructionView(null)
//        arSceneView.planeRenderer.isEnabled = false
//        return view
//    }
//
//    override fun getSessionConfiguration(session: Session): Config {
//        val config = super.getSessionConfiguration(session)
//        config.focusMode = Config.FocusMode.AUTO
//        setupAugmentedImage(config, session)
//        return config
//    }
//
//    fun setAugmentedImageUrl(augmentedImageUrl: String, augmentedImageWidth: String) {
//        this.augmentedImageUrl = augmentedImageUrl
//        try {
//            this.augmentedImageWidth =
//                java.lang.Float.valueOf(augmentedImageWidth.trim { it <= ' ' })
//        } catch (_: NumberFormatException) {
//        }
//    }
//
//    private fun setupAugmentedImage(config: Config, session: Session) {
//        // ARCore augmented image database only supports ARGB_8888 format
//        try {
//            Glide.with(requireContext()).asBitmap().load(augmentedImageUrl)
//                .apply(RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
//                .into(object : CustomTarget<Bitmap?>() {
//                    override fun onLoadCleared(placeholder: Drawable?) {}
//
//                    override fun onResourceReady(
//                        resource: Bitmap, transition: Transition<in Bitmap?>?
//                    ) {
//                        augmentedImageDatabase = AugmentedImageDatabase(session)
//                        try {
//                            if (augmentedImageWidth > 0.0f) {
//                                augmentedImageDatabase!!.addImage(
//                                    DEFAULT_IMAGE_NAME, resource, augmentedImageWidth
//                                )
//                            } else {
//                                augmentedImageDatabase!!.addImage(DEFAULT_IMAGE_NAME, resource)
//                            }
//                            config.setAugmentedImageDatabase(augmentedImageDatabase)
//                            session.configure(config)
//                        } catch (_: Exception) {
//                        }
//                    }
//                })
//        } catch (_: Exception) {
//        }
//    }
//
//    override fun onWindowFocusChanged(hasFocus: Boolean) {
////        super.onWindowFocusChanged(hasFocus)
//
//        }
//
//        companion object {
//            private val TAG = ARAugmentedFragment::class.java.simpleName
//        }
//    }
