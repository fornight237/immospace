# LedionPana Message Checker (reconstruction)

Ce projet a ete reconstitue depuis `app-release.apk`. Il ne s'agit pas du projet source original: les commentaires, noms locaux, fichiers de build et certaines constructions Kotlin/Java ne sont pas conserves dans un APK.

## Contenu

- `app/src/main/java/com/example/ledionpana_message_checker/`: neuf classes applicatives decompilees depuis `classes.dex`.
- `app/src/main/res/`: ressources minimales de l'application (layouts, chaines, theme et icones) utilisees pour compiler le projet.
- `app/src/main/jadx-resources/`: export complet des ressources JADX, conserve hors du source set compile car certaines images nine-patch des bibliotheques sont endommagees par la decompilation.
- `app/src/main/AndroidManifest.xml`: manifeste applicatif reconstruit a partir du manifeste compile.
- `app/build.gradle`: configuration approximative basee sur les metadonnees et bibliotheques detectees dans l'APK.
- `../app-release-decompiled/`: export brut complet de JADX, conserve pour reference et comparaison.

## Parametres constates dans l'APK

- Package: `com.example.ledionpana_message_checker`
- Version: `1.0` (code `1`)
- SDK minimum: `26`; SDK cible et compile: `34`
- Android Gradle Plugin: `8.9.2`
- AndroidX AppCompat `1.6.1`, RecyclerView `1.3.2`, WorkManager `2.9.0`, Material `1.11.0`
- Java est utilise pour les neuf classes propres a l'application dans l'export JADX.

## Compilation

Le projet a ete assemble avec Gradle 8.14.3, Android Gradle Plugin 8.9.2, JDK 17 et Android SDK 34. Depuis ce dossier, executer `gradle :app:assembleDebug`; l'APK debug est genere dans `app/build/outputs/apk/debug/app-debug.apk`. `android.overridePathCheck=true` est active pour le chemin Windows accentue de l'espace de travail.

Les sources Java de `app/src/main/java/` ont ete corrigees aux endroits ou JADX avait produit du code non compilable (callbacks synthetiques, signatures d'exceptions, type imbrique et helper HTTP). L'assemblage debug a reussi, mais cela ne remplace pas une verification fonctionnelle sur appareil.

La version Gson n'est pas fournie par les fichiers de version de l'APK; `2.10.1` est une valeur provisoire a verifier. La version exacte du wrapper Gradle, les dependances declarees dans le projet original et les options de compilation ne peuvent pas etre determinees avec certitude a partir de l'APK.

## Limites

JADX a termine avec des erreurs de decompilation dans certaines classes embarquees. Le dump brut inclut ces diagnostics dans les fichiers concernes. Les classes applicatives et ressources ont ete reconstruites, mais les sources doivent etre relues et testees fonctionnellement avant toute publication. Le fichier `R.java` genere par JADX n'est pas copie: Android Gradle genere sa propre classe `R`.

Pour ouvrir, selectionner ce dossier dans Android Studio et laisser Gradle synchroniser le projet. L'environnement local doit fournir JDK 17, Android SDK 34 et un acces aux depots Maven/Google.

## Réserve honnête

Je n'ai pas d'environnement Gradle / Android / build ici pour lancer un vrai build avant livraison, donc je ne peux pas garantir à 100 % qu'aucun ajustement de version ne sera nécessaire. Le README explique quoi vérifier en premier (par ex. `npx expo install --check`, `npx expo-doctor`) si un décalage de versions apparaît au build.

## Tests et migrations

- Le schéma SQLite descriptif et les migrations de référence sont disponibles dans `app/database/schema.sql`.
- Pour exécuter les tests Android instrumentés (vérifient la base SQLite) :

```bash
./gradlew connectedAndroidTest
```

- Pour exécuter les tests unitaires JVM :

```bash
./gradlew test
```
