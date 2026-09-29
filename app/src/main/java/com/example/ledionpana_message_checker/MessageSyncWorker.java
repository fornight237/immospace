package com.example.ledionpana_message_checker;

import android.content.Context;
import android.database.Cursor;
import androidx.work.ExistingWorkPolicy;
import androidx.work.ListenableWorker;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.Worker;
import androidx.work.WorkerParameters;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.concurrent.TimeUnit;

/* JADX INFO: loaded from: classes.dex */
public class MessageSyncWorker extends Worker {
    public MessageSyncWorker(Context context, WorkerParameters workerParameters) {
        super(context, workerParameters);
    }

    @Override // androidx.work.Worker
    public ListenableWorker.Result doWork() {
        DatabaseHelper databaseHelper = new DatabaseHelper(getApplicationContext());
        Cursor webhookConfig = databaseHelper.getWebhookConfig();
        if (webhookConfig == null || !webhookConfig.moveToFirst()) {
            return ListenableWorker.Result.retry();
        }
        int columnIndex = webhookConfig.getColumnIndex("lien_API");
        int columnIndex2 = webhookConfig.getColumnIndex("activation");
        if (columnIndex < 0 || columnIndex2 < 0) {
            return ListenableWorker.Result.retry();
        }
        String string = webhookConfig.getString(columnIndex);
        int i = webhookConfig.getInt(columnIndex2);
        webhookConfig.close();
        if (i != 1 || string == null || string.isEmpty()) {
            return ListenableWorker.Result.retry();
        }
        Cursor allMessages = databaseHelper.getAllMessages();
        if (allMessages != null) {
            while (allMessages.moveToNext()) {
                int colId = allMessages.getColumnIndex("id");
                int colUuid = allMessages.getColumnIndex("uuid");
                int colSender = allMessages.getColumnIndex("sender");
                int colTitle = allMessages.getColumnIndex("title");
                int colBody = allMessages.getColumnIndex("body");
                int colReceived = allMessages.getColumnIndex("received_at");
                int colStatus = allMessages.getColumnIndex("status");
                int colAttempts = allMessages.getColumnIndex("attempts");
                if (colId >= 0 && colUuid >= 0 && colBody >= 0 && colReceived >= 0 && colStatus >= 0 && colAttempts >= 0) {
                    long id = allMessages.getLong(colId);
                    String uuid = allMessages.getString(colUuid);
                    String sender = allMessages.getString(colSender);
                    String title = allMessages.getString(colTitle);
                    String body = allMessages.getString(colBody);
                    long receivedAt = allMessages.getLong(colReceived);
                    String status = allMessages.getString(colStatus);
                    int attempts = allMessages.getInt(colAttempts);

                    // Only process pending or failed messages
                    if (status != null && status.equals("SENT")) continue;

                    HashMap<String, Object> map = new HashMap<>();
                    map.put("uuid", uuid);
                    map.put("sender", sender);
                    map.put("title", title);
                    map.put("body", body);
                    map.put("received_at", receivedAt);
                    try {
                        int resp = ApiService.sendMessage(string, new Gson().toJson(map));
                        if (resp >= 200 && resp < 300) {
                            databaseHelper.updateMessageStatus(id, "SENT", attempts + 1, System.currentTimeMillis(), System.currentTimeMillis(), String.valueOf(resp));
                        } else {
                            databaseHelper.updateMessageStatus(id, "FAILED", attempts + 1, System.currentTimeMillis(), null, String.valueOf(resp));
                        }
                    } catch (Exception e) {
                        databaseHelper.updateMessageStatus(id, "PENDING", attempts + 1, System.currentTimeMillis(), null, e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            allMessages.close();
        }
        scheduleNextSync(getApplicationContext());
        return ListenableWorker.Result.success();
    }

    public static void scheduleNextSync(Context context) {
        WorkManager.getInstance(context).enqueueUniqueWork("MessageSyncWorker", ExistingWorkPolicy.REPLACE, new OneTimeWorkRequest.Builder(MessageSyncWorker.class).setInitialDelay(5L, TimeUnit.SECONDS).build());
    }
}
