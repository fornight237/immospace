package com.example.ledionpana_message_checker;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

/* JADX INFO: loaded from: classes.dex */
public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String DB_NAME = "LedionPanaDB.db";
    private static final int DB_VERSION = 2;

    public DatabaseHelper(Context context) {
        super(context, DB_NAME, (SQLiteDatabase.CursorFactory) null, DB_VERSION);
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public void onCreate(SQLiteDatabase sQLiteDatabase) {
        // messages table (new schema)
        sQLiteDatabase.execSQL("CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE, source_id INTEGER, source_name TEXT, application_package TEXT, sender TEXT, title TEXT, body TEXT, received_at INTEGER, status TEXT, attempts INTEGER DEFAULT 0, last_attempt_at INTEGER, sent_at INTEGER, server_response TEXT, created_at INTEGER)");

        // sources table
        sQLiteDatabase.execSQL("CREATE TABLE sources (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, application_package TEXT, sender_pattern TEXT, keyword_pattern TEXT, enabled INTEGER DEFAULT 1, created_at INTEGER, updated_at INTEGER)");

        // settings table
        sQLiteDatabase.execSQL("CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)");

        // keep Webhook_API for backward compatibility but do not insert default rows
        sQLiteDatabase.execSQL("CREATE TABLE Webhook_API (id INTEGER PRIMARY KEY, lien_API TEXT, activation INTEGER)");
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        if (oldVersion < 2) {
            db.beginTransaction();
            try {
                // If the old Message_Transactions exists, migrate its data into the new messages table
                // Create new tables
                db.execSQL("CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE, source_id INTEGER, source_name TEXT, application_package TEXT, sender TEXT, title TEXT, body TEXT, received_at INTEGER, status TEXT, attempts INTEGER DEFAULT 0, last_attempt_at INTEGER, sent_at INTEGER, server_response TEXT, created_at INTEGER)");
                db.execSQL("CREATE TABLE IF NOT EXISTS sources (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, application_package TEXT, sender_pattern TEXT, keyword_pattern TEXT, enabled INTEGER DEFAULT 1, created_at INTEGER, updated_at INTEGER)");
                db.execSQL("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)");
                db.execSQL("CREATE TABLE IF NOT EXISTS Webhook_API (id INTEGER PRIMARY KEY, lien_API TEXT, activation INTEGER)");

                // Check if legacy table exists
                Cursor c = db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='Message_Transactions'", null);
                if (c != null) {
                    boolean hasOld = c.moveToFirst();
                    c.close();
                    if (hasOld) {
                        // Copy legacy rows into messages with reasonable mapping
                        Cursor old = db.rawQuery("SELECT ID, ID_SIM, Date, Expediteur, Message FROM Message_Transactions", null);
                        if (old != null) {
                            while (old.moveToNext()) {
                                long oldId = old.getLong(0);
                                int idSim = old.getInt(1);
                                long date = old.getLong(2);
                                String expediteur = old.getString(3);
                                String message = old.getString(4);
                                String uuid = java.util.UUID.randomUUID().toString();
                                android.content.ContentValues cv = new android.content.ContentValues();
                                cv.put("uuid", uuid);
                                cv.putNull("source_id");
                                cv.putNull("source_name");
                                cv.putNull("application_package");
                                cv.put("sender", expediteur);
                                cv.putNull("title");
                                cv.put("body", message);
                                cv.put("received_at", date);
                                cv.put("status", "PENDING");
                                cv.put("attempts", 0);
                                cv.put("created_at", date);
                                db.insert("messages", null, cv);
                            }
                            old.close();
                        }
                        // Optionally drop old table
                        db.execSQL("DROP TABLE IF EXISTS Message_Transactions");
                    }
                }

                db.setTransactionSuccessful();
            } finally {
                db.endTransaction();
            }
        }
    }

    public long insertMessage(int sim, long date, String expediteur, String message) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        String uuid = java.util.UUID.randomUUID().toString();
        cv.put("uuid", uuid);
        cv.putNull("source_id");
        cv.putNull("source_name");
        cv.putNull("application_package");
        cv.put("sender", expediteur);
        cv.putNull("title");
        cv.put("body", message);
        cv.put("received_at", date);
        cv.put("status", "PENDING");
        cv.put("attempts", 0);
        cv.put("created_at", System.currentTimeMillis());
        return db.insert("messages", null, cv);
    }

    public Cursor getAllMessages() {
        return getReadableDatabase().rawQuery("SELECT id, uuid, source_id, source_name, application_package, sender, title, body, received_at, status, attempts, last_attempt_at, sent_at, server_response, created_at FROM messages ORDER BY received_at DESC", null);
    }

    public void deleteMessage(long id) {
        getWritableDatabase().delete("messages", "id=?", new String[]{String.valueOf(id)});
    }

    public void updateMessageStatus(long id, String status, int attempts, Long lastAttemptAt, Long sentAt, String serverResponse) {
        ContentValues cv = new ContentValues();
        cv.put("status", status);
        cv.put("attempts", attempts);
        if (lastAttemptAt != null) cv.put("last_attempt_at", lastAttemptAt);
        if (sentAt != null) cv.put("sent_at", sentAt);
        if (serverResponse != null) cv.put("server_response", serverResponse);
        getWritableDatabase().update("messages", cv, "id=?", new String[]{String.valueOf(id)});
    }

    public void updateWebhook(String str, boolean z) {
        ContentValues contentValues = new ContentValues();
        contentValues.put("lien_API", str);
        contentValues.put("activation", Integer.valueOf(z ? 1 : 0));
        getWritableDatabase().update("Webhook_API", contentValues, "id = 1", null);
    }

    public Cursor getWebhookConfig() {
        return getReadableDatabase().rawQuery("SELECT * FROM Webhook_API LIMIT 1", null);
    }
}
