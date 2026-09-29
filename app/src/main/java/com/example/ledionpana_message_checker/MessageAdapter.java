package com.example.ledionpana_message_checker;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.MessageViewHolder> {
    private List<Message> messages;

    public MessageAdapter(List<Message> list) {
        this.messages = list;
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public MessageViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new MessageViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.message_item, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public void onBindViewHolder(MessageViewHolder messageViewHolder, int i) {
        Message message = this.messages.get(i);
        messageViewHolder.senderView.setText(message.getSender());
        messageViewHolder.bodyView.setText(message.getBody());
        messageViewHolder.timestampView.setText(message.getFormattedDate());
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.messages.size();
    }

    public static class MessageViewHolder extends RecyclerView.ViewHolder {
        TextView bodyView;
        TextView senderView;
        TextView timestampView;

        public MessageViewHolder(View view) {
            super(view);
            this.senderView = (TextView) view.findViewById(R.id.senderTextView);
            this.bodyView = (TextView) view.findViewById(R.id.messageTextView);
            this.timestampView = (TextView) view.findViewById(R.id.timestampTextView);
        }
    }
}
