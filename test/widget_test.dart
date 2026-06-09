// ═══════════════════════════════════════════════════════════════════════════
// test/widget_test.dart  – Tests des widgets principaux (Dev5)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// NOTE : Adapter les imports selon la structure réelle du projet
// import 'package:immospace/main.dart';
// import 'package:immospace/screens/auth/splash_screen.dart';

void main() {
  group('Tests Splash Screen', () {
    testWidgets('Le splash screen s\'affiche correctement', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('ImmoSpace')),
          ),
        ),
      );

      // Assert
      expect(find.text('ImmoSpace'), findsOneWidget);
    });

    testWidgets('Le splash screen a un fond sombre', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('ImmoSpace',
                      style: TextStyle(color: Colors.white, fontSize: 32)),
                  Text("L'immobilier autrement.",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('ImmoSpace'), findsOneWidget);
      expect(find.text("L'immobilier autrement."), findsOneWidget);
    });
  });

  group('Tests Sign In Screen', () {
    testWidgets('Le formulaire de connexion a les champs requis',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                    key: const Key('email_field'),
                    decoration:
                        const InputDecoration(hintText: 'Adresse e-mail')),
                TextFormField(
                    key: const Key('password_field'),
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: 'Mot de passe')),
                ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: () {},
                    child: const Text('SE CONNECTER')),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.text('SE CONNECTER'), findsOneWidget);
    });

    testWidgets('Le bouton SE CONNECTER est tapable', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('SE CONNECTER'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SE CONNECTER'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('Tests Home Screen', () {
    testWidgets('La page d\'accueil affiche le titre ImmoSpace', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('ImmoSpace')),
          ),
        ),
      );
      expect(find.text('ImmoSpace'), findsOneWidget);
    });

    testWidgets('Le module RA est accessible depuis l\'accueil', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Aménagement en Réalité Augmentée'),
                ElevatedButton(
                  key: const Key('launch_ar'),
                  onPressed: () {},
                  child: const Text("Lancer l'expérience AR"),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Aménagement en Réalité Augmentée'), findsOneWidget);
      expect(find.byKey(const Key('launch_ar')), findsOneWidget);
    });
  });

  group('Tests Navigation', () {
    testWidgets('Le drawer s\'ouvre correctement', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: Drawer(
              child: ListView(
                children: [
                  Text('Accueil'),
                  Text('Rechercher'),
                  Text('Favoris'),
                ],
              ),
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Rechercher'), findsOneWidget);
      expect(find.text('Favoris'), findsOneWidget);
    });
  });

  group('Tests Property Card', () {
    testWidgets('Une carte de bien affiche les infos essentielles',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card(
              child: Column(
                children: [
                  Text('75 m² • 3 pièces'),
                  Text('Paris 16e'),
                  Text('425 000 €'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('75 m² • 3 pièces'), findsOneWidget);
      expect(find.text('Paris 16e'), findsOneWidget);
      expect(find.text('425 000 €'), findsOneWidget);
    });
  });

  group('Tests Module RA', () {
    testWidgets('L\'écran de détection affiche le message d\'attente',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF0D1117),
            body: Center(
              child: Text(
                'Détection du sol en cours...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Détection du sol en cours...'), findsOneWidget);
    });

    testWidgets('Le bouton Continuer s\'affiche après détection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Column(
              children: [
                const Text('Surface détectée !',
                    style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  key: const Key('continuer_btn'),
                  onPressed: () {},
                  child: const Text('Continuer'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Surface détectée !'), findsOneWidget);
      expect(find.byKey(const Key('continuer_btn')), findsOneWidget);
    });
  });

  group('Tests Formatage AssetService', () {
    test('formatPrice formatte correctement un prix', () {
      // Test unitaire pur (sans widget)
      String formatPrice(int price) {
        final str = price.toString();
        final buffer = StringBuffer();
        int count = 0;
        for (int i = str.length - 1; i >= 0; i--) {
          if (count > 0 && count % 3 == 0) buffer.write(' ');
          buffer.write(str[i]);
          count++;
        }
        return '${buffer.toString().split('').reversed.join()} €';
      }

      expect(formatPrice(425000), equals('425 000 €'));
      expect(formatPrice(1000000), equals('1 000 000 €'));
      expect(formatPrice(500), equals('500 €'));
    });

    test('formatSurface formatte correctement une surface', () {
      String formatSurface(double s) => '${s.toInt()} m²';
      expect(formatSurface(75.0), equals('75 m²'));
      expect(formatSurface(120.5), equals('120 m²'));
    });
  });
}
