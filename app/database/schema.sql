-- SQLite schema for messages, sources and settings

CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uuid TEXT UNIQUE NOT NULL,
  source_id INTEGER,
  source_name TEXT,
  application_package TEXT,
  sender TEXT,
  title TEXT,
  body TEXT,
  received_at INTEGER,
  status TEXT,
  attempts INTEGER DEFAULT 0,
  last_attempt_at INTEGER,
  sent_at INTEGER,
  server_response TEXT,
  created_at INTEGER
);

CREATE TABLE IF NOT EXISTS sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  application_package TEXT,
  sender_pattern TEXT,
  keyword_pattern TEXT,
  enabled INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE IF NOT EXISTS Webhook_API (
  id INTEGER PRIMARY KEY,
  lien_API TEXT,
  activation INTEGER
);
