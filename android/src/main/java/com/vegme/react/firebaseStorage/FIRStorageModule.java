package com.vegme.react.firebaseStorage;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageMetadata;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.io.FileDescriptor;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class FIRStorageModule extends ReactContextBaseJavaModule {
    private final static String TAG = FIRStorageModule.class.getCanonicalName();

    public FIRStorageModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public Map<String, Object> getConstants() {
        Map<String, Object> constants = new HashMap<>();
        return constants;
    }

    @Override
    public String getName() {
        return "RNFIRStorage";
    }

    private void sendEvent(String eventName, Object params) {
    getReactApplicationContext()
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
    }

    private Bitmap getBitmapFromUri(Uri fileUri) throws IOException {
        ParcelFileDescriptor parcelFileDescriptor =
                this.getReactApplicationContext().getContentResolver().openFileDescriptor(fileUri, "r");
        FileDescriptor fileDescriptor = parcelFileDescriptor.getFileDescriptor();
        Bitmap image = BitmapFactory.decodeFileDescriptor(fileDescriptor);
        parcelFileDescriptor.close();
        return image;
    }



    @ReactMethod
    public void uploadFileToFirebase(String localFile, String contentType, String bucket, String key, final Promise promise) throws IOException {
              Log.d(TAG, "Android uploadFileToFirebase() localfile = "+ localFile + "contentType = "+ contentType + " bucket = " + bucket + " key = " + key);
        Uri fileUri = Uri.parse(localFile);

        StorageReference mStorageRef = FirebaseStorage.getInstance().getReferenceFromUrl(bucket);
        StorageMetadata metadata = new StorageMetadata.Builder()
                                    .setContentType(contentType)
                                    .build();
        StorageReference photoRef  = mStorageRef.child(key);
        UploadTask uploadTask = photoRef.putFile(fileUri, metadata);
        
            // Observe state change events such as progress, pause, and resume

            uploadTask.addOnProgressListener(new OnProgressListener<UploadTask.TaskSnapshot>() {

            @Override
            public void onProgress(UploadTask.TaskSnapshot taskSnapshot) {
                //float progress = (taskSnapshot.getBytesTransferred() / taskSnapshot.getTotalByteCount());
                double progress = 100.0 * (taskSnapshot.getBytesTransferred() / taskSnapshot.getTotalByteCount());
                sendEvent("FirebaseUploadProgressChanged", progress);
                System.out.println("Upload is " + progress + "% done");
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception exception) {
                Log.d(TAG, "Error in uploadFileToFirebase() exception " + exception.toString());
                promise.reject(exception.toString());
            }
        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                // taskSnapshot.getMetadata() contains file metadata such as size, content-type, and download URL.

                Uri downloadUrl = taskSnapshot.getDownloadUrl();
                Log.d(TAG, "Android uploadFileToFirebase() Successfully uploaded " + downloadUrl.toString());
                promise.resolve(downloadUrl.toString());
            }
        });
   }
}
