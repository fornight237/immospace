Server-test: minimal PHP server for local testing

Prerequisites:
- PHP 7.4+ with PDO MySQL
- MySQL / MariaDB

Setup:
1. Create database (example):

```sql
CREATE DATABASE message_relay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Import schema:

```bash
mysql -u root -p message_relay < database/schema.sql
```

3. Configure DB credentials in `config/config.php`.

Run locally (for testing):

```bash
php -S 0.0.0.0:8080 -t public
```

API:
- GET /api/health -> returns `{ "status": "ok" }`
- POST /api/messages -> accepts application/json with at least `uuid` and inserts into MySQL if not duplicate

Auth:
- Set `auth_token` in `config/config.php` to require token via header `X-API-Token`. If `auth_token` is null, auth is disabled for local testing.

Security:
- Do not commit secrets. Use local configuration and environment for tokens and DB credentials.
