package com.evollu.react.firebaseStorage;

import android.content.Intent;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class StorageService extends FirebaseMessagingService{

    private static final String TAG = "MessagingStorageService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "Remote message received");
        Intent i = new Intent("com.evollu.react.fcm.ReceiveNotification");
        i.putExtra("data", remoteMessage);
        sendOrderedBroadcast(i, null);
    }
}
