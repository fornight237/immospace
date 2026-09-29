# Rapport d'audit initial — LedionPana Message Checker

Date: 2026-09-29

## Contexte
Reconstruction d'un APK Android Java disponible dans ce workspace. Objectif: adapter l'existant pour respecter nouvelles exigences (capture, filtrage, SQLite, transmission, serveur de test) sans casser la logique métier.

## Arborescence importante
- `app/` : code Android Java, `build.gradle`, `src/main/java/com/example/ledionpana_message_checker/`
- `app/src/main/java/...` : classes principales (`MainActivity`, `SmsReceiver`, `DatabaseHelper`, `MessageSyncWorker`, `WebhookManager`, `HttpHelper`, etc.)
- `app/database/schema.sql` : schéma SQLite formel ajouté
- `server-test/` : serveur PHP de test (API + README + schema MySQL)

## Versions constatées
- Android Gradle Plugin: 8.9.2
- compileSdk / targetSdk: 34
- minSdk: 26
- WorkManager: 2.9.0
- Gson: 2.10.1

## Écrans / services existants
- UI minimal (reconstituée) — `MainActivity`
- SMS capture: `SmsReceiver` (BroadcastReceiver)
- Boot receiver: `BootReceiver`
- Workers: `MessageSyncWorker`, `WebhookManager` (WorkManager)
- DB helper: `DatabaseHelper` (ancienne table `Message_Transactions` and `Webhook_API`)
- HTTP helper: `HttpHelper`

## Schéma SQLite réel (après modifications)
- `messages` (id, uuid, source_id, source_name, application_package, sender, title, body, received_at, status, attempts, last_attempt_at, sent_at, server_response, created_at)
- `sources` (id, name, application_package, sender_pattern, keyword_pattern, enabled, created_at, updated_at)
- `settings` (key, value)
- `Webhook_API` (legacy preserved, no default INSERT)

## Contrats REST réellement utilisés
- Client → configurable `lien_API` (stored in `Webhook_API` table) via `ApiService.sendMessage()` wrapper.
- Server-test provided: `GET /api/health`, `POST /api/messages` (see `server-test/public/api/messages.php`).

## Points de fragilité et incohérences détectés
- Le projet initial ne contenait PAS d'implémentation `NotificationListenerService` (capture notifications). Seule la capture SMS est présente (`SmsReceiver`).
- Ancienne `DatabaseHelper` insérait par défaut une ligne dans `Webhook_API` à la création — j'ai supprimé ce comportement pour respecter «pas de données fictives».
- Schéma original (`Message_Transactions`) ne suivait pas les exigences (pas d'UUID, pas de status/attempts). J'ai ajouté migration v2.
- Le code précédent supprimait les messages après un envoi réussi. J'ai changé le comportement pour conserver l'historique et mettre à jour `status`.
- Aucun code Expo / React Native / TypeScript n'existe dans ce repo — la cible Expo/TS n'est pas présente ici.

## Modifications appliquées (liste précise)
1. `DatabaseHelper.java`: bumped DB_VERSION -> 2, created `messages`, `sources`, `settings`, preserved `Webhook_API` without default INSERT, added migration path from legacy `Message_Transactions` (copie des données), added `insertMessage(...)` returning row ID and `updateMessageStatus(...)`.
2. `SmsReceiver.java`: now uses `insertMessage(...)` and passes `message_id` to `WebhookManager`.
3. `WebhookManager.java`: accepts `message_id`, fetches the message, uses `ApiService.sendMessage()` and updates message `status/attempts/last_attempt_at/sent_at` instead of deleting rows.
4. `MessageSyncWorker.java`: iterates `messages` table, sends pending/failed messages via `ApiService`, updates status and attempts.
5. Added `ApiService.java` as a thin wrapper for `HttpHelper` (`testConnection`, `sendMessage`).
6. Added formal SQLite schema file: `app/database/schema.sql`.
7. Added instrumentation test `DatabaseInstrumentedTest.java` to verify no default `Webhook_API` row and that `insertMessage` creates `PENDING` with `uuid`.
8. Updated `app/build.gradle` with test deps and test runner.
9. Created `server-test/` directory with PHP API endpoints, MySQL schema (`server-test/database/schema.sql`), config template, dashboard and README.
10. Updated `README.md` with the honest reserve and test commands.

## Vérifications effectuées
- Static checks on modified Java files reported no errors via workspace diagnostics.
- `server-test` PHP files reviewed for correctness (PDO used, duplicate UUID check, Content-Type enforced). SQL schema for MySQL created and indices added.

## Ce qui reste à faire / recommandations (actions nécessaires localement)
1. Tests Android instrumentés: run on device/emulator to validate DB migrations and insertion logic:

```bash
./gradlew connectedAndroidTest
```

2. Unit tests JVM:

```bash
./gradlew test
```

3. Build integrité: run a local Gradle build and test install on device/emulator:

```bash
./gradlew :app:assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

4. Serveur-test: start MySQL, import `server-test/database/schema.sql`, configure `server-test/config/config.php`, then run:

```bash
php -S 0.0.0.0:8080 -t server-test/public
# test health
curl http://<host>:8080/api/health
# test post (replace uuid)
curl -X POST -H "Content-Type: application/json" -d '{"uuid":"<uuid>","body":"test"}' http://<host>:8080/api/messages
```

5. Implement `NotificationListenerService` if notification capture is required by product spec (currently absent). This must be added as a new service class and declared in `AndroidManifest.xml` with proper permission and an opt-in flow in UI.

6. Add migrations/unit tests for additional edge cases (duplicate UUID handling, retry/backoff behaviour) if needed.

## Conclusion
Les changements appliqués alignent la base locale et le mécanisme de transmission sur les exigences (UUID, status, retry, pas de données fictives, conservation d'historique). Le point majeur restant est l'absence d'un `NotificationListenerService` pour la capture des notifications — uniquement la capture SMS est présente. Les tests instrumentés et le build final doivent être exécutés localement (JDK/Android SDK/Gradle) pour valider les migrations et l'intégration runtime.

---

Fichiers clés modifiés/créés:
- `app/src/main/java/com/example/ledionpana_message_checker/DatabaseHelper.java`
- `app/src/main/java/com/example/ledionpana_message_checker/SmsReceiver.java`
- `app/src/main/java/com/example/ledionpana_message_checker/MessageSyncWorker.java`
- `app/src/main/java/com/example/ledionpana_message_checker/WebhookManager.java`
- `app/src/main/java/com/example/ledionpana_message_checker/ApiService.java`
- `app/database/schema.sql`
- `app/src/androidTest/.../DatabaseInstrumentedTest.java`
- `server-test/` (API + schema + README)
- `README.md` (reserve honnête + instructions)

Si tu veux, je peux maintenant:
- exécuter localement les tests (je te fournis les commandes et je peux tenter des validations statiques supplémentaires), ou
- implémenter `NotificationListenerService` minimal et lier à la même logique de filtrage, ou
- produire un patch commit-ready et un changelog détaillé pour la livraison.

Dis-moi quelle action tu veux que je fasse ensuite.