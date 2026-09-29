package com.example.ledionpana_message_checker;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class SmsReceiver extends BroadcastReceiver {
    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        Bundle extras = intent.getExtras();
        if (extras != null) {
            Object[] objArr = (Object[]) extras.get("pdus");
            String string = extras.getString("format");
            int i = extras.containsKey("subscription") ? extras.getInt("subscription") : -1;
            if (objArr != null) {
                for (Object obj : objArr) {
                    SmsMessage smsMessageCreateFromPdu = SmsMessage.createFromPdu((byte[]) obj, string);
                    if (smsMessageCreateFromPdu != null) {
                        String displayOriginatingAddress = smsMessageCreateFromPdu.getDisplayOriginatingAddress();
                        String messageBody = smsMessageCreateFromPdu.getMessageBody();
                        long timestampMillis = smsMessageCreateFromPdu.getTimestampMillis();
                        if (displayOriginatingAddress != null && displayOriginatingAddress.matches("(?i)(MTN ?Money|Mobile ?Money|Orange ?Money)")) {
                            DatabaseHelper db = new DatabaseHelper(context);
                            long messageId = db.insertMessage(i, timestampMillis, displayOriginatingAddress, messageBody);
                            Intent intent2 = new Intent(context, (Class<?>) WebhookManager.class);
                            intent2.putExtra("id_sim", i);
                            intent2.putExtra("date", timestampMillis);
                            intent2.putExtra("expediteur", displayOriginatingAddress);
                            intent2.putExtra("message", messageBody);
                            intent2.putExtra("message_id", messageId);
                            WebhookManager.enqueueWork(context, intent2);
                            Log.d("SmsReceiver", "Message Mobile Money intercepté et envoyé au webhook (message_id=" + messageId + ")");
                        }
                    }
                }
            }
        }
    }
}
