package biz.uniquegood.realworld.sunguard.ar.module;

import android.annotation.TargetApi;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.Log;
import android.view.LayoutInflater;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DecodeFormat;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.ImageViewTarget;
import com.bumptech.glide.request.transition.Transition;
import com.google.ar.core.AugmentedImage;
import com.google.ar.sceneform.AnchorNode;
import com.google.ar.sceneform.Node;
import com.google.ar.sceneform.math.Quaternion;
import com.google.ar.sceneform.math.Vector3;
import com.google.ar.sceneform.rendering.FixedWidthViewSizer;
import com.google.ar.sceneform.rendering.ViewRenderable;

import java.util.concurrent.CompletableFuture;

import biz.uniquegood.realworld.sunguard.ar.R;

public class AROverlayImage extends AnchorNode {
    private static final String TAG = AROverlayImage.class.getSimpleName();

    private ImageView imageOverlay;
    // Augmented image is the target image in ARCore
    private AugmentedImage image;
    private final Activity activity;
    private final String overlayImageUrl;

    private CompletableFuture<ViewRenderable> completableFuture;

    AROverlayImage(Activity activity, String overlayImageUrl) {
        this.activity = activity;
        this.overlayImageUrl = overlayImageUrl;

        LayoutInflater inflater = activity.getLayoutInflater();
        imageOverlay = (ImageView) inflater.inflate(R.layout.ar_tracking_image, null);

        initViewRenderable();
    }

    @TargetApi(Build.VERSION_CODES.N)
    private void initViewRenderable() {
        buildViewRenderable();
        setOverlayImage();
    }

    @TargetApi(Build.VERSION_CODES.N)
    private void setOverlayImage() {
        String extension = overlayImageUrl.substring(overlayImageUrl.length() - 4);
        boolean isGif = extension.contains(".gif");

        if (isGif) {
            Glide.with(activity)
                    .asGif()
                    .load(overlayImageUrl)
                    .apply(new RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
                    .into(new ImageViewTarget<GifDrawable>(imageOverlay) {
                        @Override
                        protected void setResource(@Nullable GifDrawable resource) {
                            imageOverlay.setImageDrawable(resource);
                        }
                    });
        } else {
            Glide.with(activity)
                    .asBitmap()
                    .load(overlayImageUrl)
                    .apply(new RequestOptions().format(DecodeFormat.PREFER_ARGB_8888))
                    .encodeFormat(Bitmap.CompressFormat.PNG)
                    .into(new CustomTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                            imageOverlay.setImageBitmap(resource);
                        }

                        @Override
                        public void onLoadCleared(@Nullable Drawable placeholder) {

                        }
                    });
        }
    }

    @TargetApi(Build.VERSION_CODES.N)
    private void buildViewRenderable() {
        // code to prepare overlay image in background
        completableFuture = ViewRenderable.builder()
                .setView(activity, imageOverlay)
                .build();
    }

    @TargetApi(Build.VERSION_CODES.N)
    public void setImage(AugmentedImage image) {
        this.image = image;

        // if viewRenderable is not loaded wait and recursively call setImage() again
        if (!completableFuture.isDone()) {
            CompletableFuture.allOf(completableFuture)
                    .thenAccept((Void v) -> setImage(image))
                    .exceptionally(
                            throwable -> {
                                Log.e(TAG, "Loading viewRenderable not finished ", throwable);
                                Log.e("SHIM", "Loading viewRenderable not finished ", throwable);
                                return null;
                            }
                    );
            return;
        }

        // set the anchor to the center of augmented image
        setAnchor(image.createAnchor(image.getCenterPose()));

        ViewRenderable viewRenderable = completableFuture.getNow(null);

        // align viewRenderable to center of image
        viewRenderable.setHorizontalAlignment(ViewRenderable.HorizontalAlignment.CENTER);
        viewRenderable.setVerticalAlignment(ViewRenderable.VerticalAlignment.CENTER);

        // set size of viewRenderer to image in order to overlap
        viewRenderable.setSizer(new FixedWidthViewSizer(image.getExtentX()));

        // remove shadow effects
        viewRenderable.setShadowReceiver(false);
        viewRenderable.setShadowCaster(false);

        // rotate node 90 degrees along the x-axis
        Vector3 axis = new Vector3(-1, 0, 0);
        float rotation = 90.f;
        Quaternion angle = Quaternion.axisAngle(axis, rotation);

        Node node = new Node();
        node.setParent(this);
        node.setLocalRotation(angle);
        node.setRenderable(viewRenderable);
    }

}

