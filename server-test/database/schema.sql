-- MySQL schema for server-test messages table

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid VARCHAR(100) NOT NULL UNIQUE,
  device_id VARCHAR(100),
  source VARCHAR(255),
  application VARCHAR(255),
  sender TEXT,
  title TEXT,
  body TEXT,
  received_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_received_at (received_at),
  INDEX idx_source (source),
  INDEX idx_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
