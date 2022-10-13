package io.lowapple.flutter.plugin.ar_image_tracking.flutter_ar_image_tracking_f2n;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DecodeFormat;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.google.ar.core.AugmentedImageDatabase;
import com.google.ar.core.Config;
import com.google.ar.core.Session;
import com.google.ar.sceneform.ux.ArFragment;


/**
 * AugmentedImageFragment is a view showing the target image that should be
 * tracked and become the base to render a 2D or 3D model on top of.
 * <p>
 * An AugmentedImage, according to the documentation, is an object in ARCore
 * that lets you build AR apps that can respond to 2D images, such as posters
 * or product packaging, in the user's environment.
 * <p>
 * jhshim@uniquegood.biz
 */
public class ARAugmentedFragment extends ArFragment {
    private static final String TAG = ARAugmentedFragment.class.getSimpleName();

    private final String DEFAULT_IMAGE_NAME = "default";
    private String augmentedImageUrl = "";
    private float augmentedImageWidth = 0.0f;

    private Context context;
    private AugmentedImageDatabase augmentedImageDatabase;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.context = context;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);

        // Hide default plane discovery controller
        getPlaneDiscoveryController().hide();
        getPlaneDiscoveryController().setInstructionView(null);
        getArSceneView().getPlaneRenderer().setEnabled(false);

        return view;
    }

    @Override
    protected Config getSessionConfiguration(Session session) {
        Config config = super.getSessionConfiguration(session);
        config.setFocusMode(Config.FocusMode.AUTO);

        setupAugmentedImage(config, session);

        return config;
    }

    public void setAugmentedImageUrl(String augmentedImageUrl, String augmentedImageWidth) {
        this.augmentedImageUrl = augmentedImageUrl;

        try {
            this.augmentedImageWidth = Float.valueOf(augmentedImageWidth.trim());
        } catch (NumberFormatException e) {
        }
    }

    private void setupAugmentedImage(Config config, Session session) {
        // ARCore augmented image database only supports ARGB_8888 format
        try {
            Glide.with(context)
                    .asBitmap()
                    .load(augmentedImageUrl)
                    .apply(new RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
                    .into(new CustomTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                            augmentedImageDatabase = new AugmentedImageDatabase(session);

                            try {
                                if (augmentedImageWidth > 0.0f) {
                                    augmentedImageDatabase.addImage(DEFAULT_IMAGE_NAME, resource, augmentedImageWidth);
                                } else {
                                    augmentedImageDatabase.addImage(DEFAULT_IMAGE_NAME, resource);
                                }
                                config.setAugmentedImageDatabase(augmentedImageDatabase);
                                session.configure(config);
                            } catch (Exception e) {
                            }
                        }

                        @Override
                        public void onLoadCleared(@Nullable Drawable placeholder) {
                        }
                    });
        } catch (Exception e) {
        }
    }
}
