package com.example.ledionpana_message_checker;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import androidx.work.Data;
import androidx.work.ListenableWorker;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.Worker;
import androidx.work.WorkerParameters;
import com.google.gson.Gson;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class WebhookManager extends Worker {
    public WebhookManager(Context context, WorkerParameters workerParameters) {
        super(context, workerParameters);
    }

    @Override // androidx.work.Worker
    public ListenableWorker.Result doWork() {
        long messageId = getInputData().getLong("message_id", -1L);
        DatabaseHelper db = new DatabaseHelper(getApplicationContext());
        Cursor webhookConfig = db.getWebhookConfig();
        if (webhookConfig == null || !webhookConfig.moveToFirst()) {
            return ListenableWorker.Result.retry();
        }
        int colUrl = webhookConfig.getColumnIndex("lien_API");
        int colActive = webhookConfig.getColumnIndex("activation");
        if (colUrl < 0 || colActive < 0) {
            webhookConfig.close();
            return ListenableWorker.Result.retry();
        }
        String url = webhookConfig.getString(colUrl);
        int active = webhookConfig.getInt(colActive);
        webhookConfig.close();
        if (active != 1 || url == null || url.isEmpty()) {
            return ListenableWorker.Result.retry();
        }

        try {
            if (messageId > 0) {
                Cursor c = db.getReadableDatabase().rawQuery("SELECT id, uuid, sender, title, body, received_at, attempts FROM messages WHERE id=?", new String[]{String.valueOf(messageId)});
                if (c != null && c.moveToFirst()) {
                    long id = c.getLong(0);
                    String uuid = c.getString(1);
                    String sender = c.getString(2);
                    String title = c.getString(3);
                    String body = c.getString(4);
                    long receivedAt = c.getLong(5);
                    int attempts = c.getInt(6);
                    c.close();

                    HashMap<String, Object> map = new HashMap<>();
                    map.put("uuid", uuid);
                    map.put("sender", sender);
                    map.put("title", title);
                    map.put("body", body);
                    map.put("received_at", receivedAt);
                    String json = new Gson().toJson(map);

                    try {
                        int statusCode = ApiService.sendMessage(url, json);
                        if (statusCode >= 200 && statusCode < 300) {
                            db.updateMessageStatus(id, "SENT", attempts + 1, System.currentTimeMillis(), System.currentTimeMillis(), String.valueOf(statusCode));
                            return ListenableWorker.Result.success();
                        } else {
                            db.updateMessageStatus(id, "FAILED", attempts + 1, System.currentTimeMillis(), null, String.valueOf(statusCode));
                            return ListenableWorker.Result.retry();
                        }
                    } catch (Exception e) {
                        db.updateMessageStatus(id, "PENDING", attempts + 1, System.currentTimeMillis(), null, e.getMessage());
                        e.printStackTrace();
                        return ListenableWorker.Result.retry();
                    }
                }
                if (c != null) c.close();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return ListenableWorker.Result.retry();
    }

    public static void enqueueWork(Context context, Intent intent) {
        Data.Builder dataBuilder = new Data.Builder();
        dataBuilder.putString("id_sim", String.valueOf(intent.getIntExtra("id_sim", 0)));
        dataBuilder.putString("date", String.valueOf(intent.getLongExtra("date", 0L)));
        if (intent.getStringExtra("expediteur") != null) dataBuilder.putString("expediteur", intent.getStringExtra("expediteur"));
        if (intent.getStringExtra("message") != null) dataBuilder.putString("message", intent.getStringExtra("message"));
        if (intent.hasExtra("message_id")) dataBuilder.putLong("message_id", intent.getLongExtra("message_id", -1L));
        WorkManager.getInstance(context).enqueue(new OneTimeWorkRequest.Builder(WebhookManager.class).setInputData(dataBuilder.build()).build());
    }
}
