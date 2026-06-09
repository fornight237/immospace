# 🏠 ImmoSpace

> **Visite Immobilière Immersive en Réalité Augmentée et Réalité Virtuelle**  
> Université UY1 – ICT4D | UE : ICT218 – Génie Logiciel | Flutter

---

## 📋 Présentation

**ImmoSpace** est une application mobile immersive développée avec Flutter permettant :

- 🥽 **Visites Virtuelles 360°** — explorer un logement pièce par pièce grâce à des panoramas interactifs
- 🪑 **Réalité Augmentée** — placer, pivoter et redimensionner des meubles 3D dans votre espace réel
- 🏡 **Catalogue immobilier** — parcourir des biens, consulter les détails, contacter les agents

---

## 👥 Équipe

| Développeur | Rôle | Branche |
|-------------|------|---------|
| Dev 1 | Chef de projet & Architecture | `main` / `dev` |
| Dev 2 | UI/UX & Interfaces | `feature/ui` |
| Dev 3 | Module RV 360° | `feature/vr` |
| Dev 4 | Module RA (ARCore) | `feature/ar` |
| Dev 5 | Assets, Tests & Documentation | `feature/assets-tests` |

---

## 🗂️ Structure du projet

```
immospace/
├── lib/
│   ├── core/
│   │   ├── app_theme.dart        # Couleurs, typographie, thème
│   │   └── app_routes.dart       # Navigation centralisée
│   ├── models/
│   │   └── models.dart           # Entités : Property, User, Furniture...
│   ├── services/
│   │   ├── data_service.dart     # Chargement données JSON (Dev5)
│   │   └── asset_service.dart    # Gestion images/assets (Dev5)
│   ├── screens/
│   │   ├── auth/                 # Splash, Sign In, Sign Up, Forgot
│   │   ├── home/                 # Dashboard + Drawer
│   │   ├── search/               # Recherche de biens
│   │   ├── property/             # Détail d'un bien
│   │   ├── favorites/            # Mes favoris
│   │   ├── appointments/         # Rendez-vous
│   │   ├── messages/             # Messagerie
│   │   ├── notifications/        # Notifications
│   │   ├── profile/              # Mon profil
│   │   ├── settings/             # Paramètres
│   │   ├── ar/                   # Module RA (détection + placement)
│   │   └── vr/                   # Module RV 360°
│   ├── widgets/
│   │   └── common_widgets.dart   # Composants réutilisables
│   └── main.dart
├── assets/
│   ├── images/                   # Photos des biens et meubles
│   ├── panoramas/                # Images 360° (équirectangulaires)
│   ├── models_3d/                # Modèles GLB/GLTF
│   ├── icons/                    # Icônes SVG personnalisées
│   ├── fonts/                    # Polices Playfair + Inter
│   └── data/
│       └── immospace_data.json   # Données locales (biens + meubles)
├── test/
│   ├── data_service_test.dart    # Tests service données (Dev5)
│   └── widget_test.dart          # Tests widgets (Dev5)
└── pubspec.yaml
```

---

## 🎨 Design System

| Élément | Valeur |
|---------|--------|
| Couleur primaire (or) | `#C9A84C` |
| Background clair | `#FAF7F2` |
| Background sombre | `#0D1117` |
| Succès | `#4CAF50` |
| Erreur | `#E57373` |
| Police titres | Playfair Display |
| Police corps | Inter |

---

## 📦 Packages utilisés

| Package | Version | Usage |
|---------|---------|-------|
| `provider` | ^6.1.2 | Gestion d'état |
| `panorama_viewer` | ^1.0.1 | Visite 360° |
| `ar_flutter_plugin` | ^0.7.3 | ARCore / ARKit |
| `model_viewer_plus` | ^1.7.2 | Modèles GLB/GLTF |
| `cached_network_image` | ^3.3.1 | Chargement images |
| `permission_handler` | ^11.3.0 | Permissions caméra |
| `sensors_plus` | ^5.0.1 | Gyroscope |

---

## 🚀 Installation

### Prérequis
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Android SDK (ARCore compatible — Android 10+)
- Git

### Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/fornight237/immospace.git
cd immospace

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier l'environnement
flutter doctor

# 4. Lancer l'application
flutter run
```

---

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests avec rapport de couverture
flutter test --coverage

# Test d'un fichier spécifique
flutter test test/data_service_test.dart
flutter test test/widget_test.dart
```

### Résultats attendus
- ✅ DataService – Biens Immobiliers : 7 tests
- ✅ DataService – Meubles : 5 tests
- ✅ DataService – Pièces et Panoramas : 4 tests
- ✅ DataService – Recherche : 3 tests
- ✅ Tests Widgets : 8 tests
- ✅ Tests Formatage : 2 tests

---

## 📱 Fonctionnalités

### Module A – Tableau de bord & Catalogue
- [x] Splash screen avec animation
- [x] Authentification (Sign In / Sign Up / Mot de passe oublié)
- [x] Dashboard avec drawer latéral
- [x] Catalogue de biens immobiliers
- [x] Détail d'un bien (galerie, stats, contact, équipements)
- [x] Favoris
- [x] Recherche avec filtres
- [x] Rendez-vous
- [x] Messagerie
- [x] Notifications
- [x] Profil & Paramètres

### Module B – Visite Virtuelle 360°
- [x] Vue panoramique équirectangulaire
- [x] Navigation par gyroscope
- [x] Hotspots interactifs (Salon → Cuisine → Chambre → SdB)
- [x] Transitions entre pièces

### Module C – Réalité Augmentée
- [x] Détection de surfaces horizontales
- [x] Interface caméra avec guide visuel (cadre doré → vert)
- [x] Catalogue de meubles 3D (Canapé, Fauteuil, Table, Lampe, Bibliothèque, Meuble TV)
- [x] Placement, rotation, redimensionnement des objets
- [x] Compteur d'objets placés

---

## 🔐 Permissions Android

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.camera.ar" android:required="true"/>
```

---

## 📅 Planning

| Semaine | Dates | Objectifs | Statut |
|---------|-------|-----------|--------|
| S1 | 31 Mai – 2 Juin | Architecture + Setup | ✅ |
| S2 | 3 – 5 Juin | UI + RV | ✅ |
| S3 | 6 – 8 Juin | Module RA | ✅ |
| Final | 9 – 10 Juin | Intégration + Soutenance | 🔄 |

---

## ⚠️ Risques identifiés

| Risque | Impact | Solution |
|--------|--------|----------|
| Incompatibilité ARCore | Élevé | Simulateur + fallback UI |
| Bugs mémoire 3D | Élevé | Compression assets GLB |
| Conflits Git | Moyen | Branches feature/* séparées |
| Performance panoramas | Moyen | Cached images + lazy loading |

---

## 📄 Livrables

- [x] Code source Flutter (GitHub)
- [ ] APK Android signé
- [x] Assets 3D (GLB/GLTF)
- [x] Images panoramiques
- [x] Données JSON
- [x] Tests fonctionnels
- [ ] Rapport technique
- [ ] Manuel utilisateur
- [ ] Présentation PowerPoint

---

## 👨‍💻 Contribution (Convention de commits)

```bash
feat: ajout module RA
fix: correction bug rotation panorama
ui: amélioration dashboard
test: ajout tests data_service
docs: mise à jour README
assets: ajout modèles 3D meubles
```

---

*ImmoSpace v1.0 – ICT218 – UY1 ICT4D – Juin 2026*
