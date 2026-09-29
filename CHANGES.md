# Changelog

## 2026-09-29
- DB migration to v2: new `messages`, `sources`, `settings` tables; legacy `Message_Transactions` migrated.
- `DatabaseHelper`: removed default INSERT into `Webhook_API`, added `insertMessage` returning row id and `updateMessageStatus`.
- `SmsReceiver`: now persists message and passes `message_id` to worker.
- `WebhookManager` & `MessageSyncWorker`: updated to update message status/attempts instead of deleting rows.
- Added `ApiService` wrapper.
- Added `NotificationListenerServiceImpl` to support notifications capture (minimal implementation).
- Added `server-test/` PHP test server with `api/health` and `api/messages` endpoints and MySQL schema.
- Added `app/database/schema.sql` and test `DatabaseInstrumentedTest`.
- Added CI workflow `.github/workflows/ci.yml` to run Gradle tests and lint.
- Updated `README.md` with reserve and test instructions.
