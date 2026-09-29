package com.example.ledionpana_message_checker;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public class Message {
    private String body;
    private long id;
    private String sender;
    private int sim;
    private long timestamp;

    public Message(long j, int i, long j2, String str, String str2) {
        this.id = j;
        this.sim = i;
        this.timestamp = j2;
        this.sender = str;
        this.body = str2;
    }

    public long getId() {
        return this.id;
    }

    public int getSim() {
        return this.sim;
    }

    public String getSender() {
        return this.sender;
    }

    public String getBody() {
        return this.body;
    }

    public long getTimestamp() {
        return this.timestamp;
    }

    public String getFormattedDate() {
        return new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault()).format(new Date(this.timestamp));
    }
}
