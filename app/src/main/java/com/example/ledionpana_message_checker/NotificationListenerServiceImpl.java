package com.example.ledionpana_message_checker;

import android.app.Notification;
import android.os.Bundle;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

public class NotificationListenerServiceImpl extends NotificationListenerService {
    private static final String TAG = "NotifListener";

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        try {
            String pkg = sbn.getPackageName();
            Notification n = sbn.getNotification();
            if (n == null) return;
            Bundle extras = n.extras;
            String title = extras != null ? extras.getString(Notification.EXTRA_TITLE) : null;
            CharSequence textCs = extras != null ? extras.getCharSequence(Notification.EXTRA_TEXT) : null;
            String text = textCs != null ? textCs.toString() : null;
            long time = sbn.getPostTime();

            // Basic filter: ignore system notifications
            if (pkg == null || pkg.contains("android")) return;

            // Insert into DB as a message (preserve existing SMS flow semantics)
            DatabaseHelper db = new DatabaseHelper(getApplicationContext());
            long id = db.insertMessage(-1, time, pkg, text != null ? text : "");
            Log.d(TAG, "Notification captured from " + pkg + ", saved id=" + id);

            // Enqueue webhook work for this message
            android.content.Intent intent = new android.content.Intent(getApplicationContext(), WebhookManager.class);
            intent.putExtra("message_id", id);
            WebhookManager.enqueueWork(getApplicationContext(), intent);
        } catch (Exception e) {
            Log.e(TAG, "Error handling notification", e);
        }
    }
}
