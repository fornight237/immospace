package com.example.ledionpana_message_checker;

import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class MainActivity extends AppCompatActivity {
    private MessageAdapter adapter;
    private DatabaseHelper db;
    private RecyclerView recyclerView;
    private Runnable refreshRunnable;
    private TextView webhookStatusView;
    private List<Message> messages = new ArrayList();
    private Handler handler = new Handler();

    @Override // androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_main);
        this.db = new DatabaseHelper(this);
        RecyclerView recyclerView = (RecyclerView) findViewById(R.id.messageList);
        this.recyclerView = recyclerView;
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        MessageAdapter messageAdapter = new MessageAdapter(this.messages);
        this.adapter = messageAdapter;
        this.recyclerView.setAdapter(messageAdapter);
        MessageSyncWorker.scheduleNextSync(this);
        this.webhookStatusView = (TextView) findViewById(R.id.webhookStatusTextView);
        final EditText editText = (EditText) findViewById(R.id.webhookInput);
        Button button = (Button) findViewById(R.id.validateButton);
        Button button2 = (Button) findViewById(R.id.activateButton);
        button.setOnClickListener(new View.OnClickListener() { // from class: com.example.ledionpana_message_checker.MainActivity$$ExternalSyntheticLambda0
            @Override // android.view.View.OnClickListener
            public final void onClick(View view) {
                MainActivity.this.m72xec5bed07(editText, view);
            }
        });
        button2.setOnClickListener(new View.OnClickListener() { // from class: com.example.ledionpana_message_checker.MainActivity$$ExternalSyntheticLambda1
            @Override // android.view.View.OnClickListener
            public final void onClick(View view) {
                MainActivity.this.m73x79969e88(view);
            }
        });
        Runnable runnable = new Runnable() { // from class: com.example.ledionpana_message_checker.MainActivity.1
            @Override // java.lang.Runnable
            public void run() {
                MainActivity.this.loadMessages();
                MainActivity.this.loadWebhookStatus();
                MainActivity.this.handler.postDelayed(this, 2000L);
            }
        };
        this.refreshRunnable = runnable;
        this.handler.post(runnable);
    }

    /* JADX INFO: renamed from: lambda$onCreate$0$com-example-ledionpana_message_checker-MainActivity, reason: not valid java name */
    /* synthetic */ void m72xec5bed07(EditText editText, View view) {
        String strTrim = editText.getText().toString().trim();
        if (strTrim.isEmpty()) {
            return;
        }
        this.db.updateWebhook(strTrim, false);
        loadWebhookStatus();
    }

    /* JADX INFO: renamed from: lambda$onCreate$1$com-example-ledionpana_message_checker-MainActivity, reason: not valid java name */
    /* synthetic */ void m73x79969e88(View view) {
        Cursor webhookConfig = this.db.getWebhookConfig();
        if (webhookConfig == null || !webhookConfig.moveToFirst()) {
            return;
        }
        int columnIndex = webhookConfig.getColumnIndex("lien_API");
        if (columnIndex >= 0) {
            String string = webhookConfig.getString(columnIndex);
            if (!string.isEmpty()) {
                this.db.updateWebhook(string, true);
                loadWebhookStatus();
            }
        }
        webhookConfig.close();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void loadMessages() {
        this.messages.clear();
        Cursor allMessages = this.db.getAllMessages();
        if (allMessages != null) {
            while (allMessages.moveToNext()) {
                int columnIndex = allMessages.getColumnIndex("ID");
                int columnIndex2 = allMessages.getColumnIndex("ID_SIM");
                int columnIndex3 = allMessages.getColumnIndex("Date");
                int columnIndex4 = allMessages.getColumnIndex("Expediteur");
                int columnIndex5 = allMessages.getColumnIndex("Message");
                if (columnIndex >= 0 && columnIndex2 >= 0 && columnIndex3 >= 0 && columnIndex4 >= 0 && columnIndex5 >= 0) {
                    this.messages.add(new Message(allMessages.getLong(columnIndex), allMessages.getInt(columnIndex2), allMessages.getLong(columnIndex3), allMessages.getString(columnIndex4), allMessages.getString(columnIndex5)));
                }
            }
            allMessages.close();
        }
        this.adapter.notifyDataSetChanged();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void loadWebhookStatus() {
        Cursor webhookConfig = this.db.getWebhookConfig();
        if (webhookConfig == null || !webhookConfig.moveToFirst()) {
            return;
        }
        int columnIndex = webhookConfig.getColumnIndex("lien_API");
        int columnIndex2 = webhookConfig.getColumnIndex("activation");
        if (columnIndex >= 0 && columnIndex2 >= 0) {
            String string = webhookConfig.getString(columnIndex);
            int i = webhookConfig.getInt(columnIndex2);
            StringBuilder sb = new StringBuilder("Webhook URL: ");
            if (string.isEmpty()) {
                string = "(non configuré)";
            }
            this.webhookStatusView.setText(sb.append(string).append("\nActivation: ").append(i == 1 ? "Activé" : "Désactivé").toString());
        }
        webhookConfig.close();
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onDestroy() {
        super.onDestroy();
        this.handler.removeCallbacks(this.refreshRunnable);
        this.db.close();
    }
}
