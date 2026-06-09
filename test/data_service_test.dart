// ═══════════════════════════════════════════════════════════════════════════
// test/data_service_test.dart  – Tests du service de données (Dev5)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/data_service.dart';

void main() {
  // Initialise le binding Flutter pour les tests d'assets
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataService – Biens Immobiliers', () {
    setUp(() => DataService.clearCache());

    test('getProperties() retourne une liste non vide', () async {
      final properties = await DataService.getProperties();
      expect(properties, isNotEmpty);
    });

    test('getProperties() retourne au moins 3 biens', () async {
      final properties = await DataService.getProperties();
      expect(properties.length, greaterThanOrEqualTo(3));
    });

    test('chaque bien possède les champs obligatoires', () async {
      final properties = await DataService.getProperties();
      for (final p in properties) {
        expect(p.containsKey('id'), isTrue, reason: 'Champ id manquant');
        expect(p.containsKey('titre'), isTrue, reason: 'Champ titre manquant');
        expect(p.containsKey('prix'), isTrue, reason: 'Champ prix manquant');
        expect(p.containsKey('localisation'), isTrue,
            reason: 'Champ localisation manquant');
        expect(p.containsKey('surface'), isTrue,
            reason: 'Champ surface manquant');
        expect(p.containsKey('images'), isTrue,
            reason: 'Champ images manquant');
      }
    });

    test('getPropertyById() retourne le bon bien', () async {
      final property = await DataService.getPropertyById('prop_001');
      expect(property, isNotNull);
      expect(property!['id'], equals('prop_001'));
      expect(property['localisation'], equals('Paris 16e'));
    });

    test('getPropertyById() retourne null pour un ID inexistant', () async {
      final property = await DataService.getPropertyById('id_inexistant');
      expect(property, isNull);
    });

    test('le prix est un nombre positif', () async {
      final properties = await DataService.getProperties();
      for (final p in properties) {
        final prix = p['prix'] as num;
        expect(prix, greaterThan(0));
      }
    });

    test('la surface est positive', () async {
      final properties = await DataService.getProperties();
      for (final p in properties) {
        final surface = p['surface'] as num;
        expect(surface, greaterThan(0));
      }
    });
  });

  group('DataService – Meubles', () {
    setUp(() => DataService.clearCache());

    test('getFurniture() retourne une liste non vide', () async {
      final meubles = await DataService.getFurniture();
      expect(meubles, isNotEmpty);
    });

    test('getFurniture() retourne au moins 6 meubles', () async {
      final meubles = await DataService.getFurniture();
      expect(meubles.length, greaterThanOrEqualTo(6));
    });

    test('chaque meuble a les champs requis', () async {
      final meubles = await DataService.getFurniture();
      for (final m in meubles) {
        expect(m.containsKey('id'), isTrue);
        expect(m.containsKey('nom'), isTrue);
        expect(m.containsKey('categorie'), isTrue);
        expect(m.containsKey('modele_3d'), isTrue);
        expect(m.containsKey('description'), isTrue);
      }
    });

    test('getFurnitureByCategory() filtre correctement', () async {
      final salon = await DataService.getFurnitureByCategory('salon');
      expect(salon, isNotEmpty);
      for (final m in salon) {
        expect(m['categorie'], equals('salon'));
      }
    });

    test('getFurnitureCategories() retourne les catégories', () async {
      final cats = await DataService.getFurnitureCategories();
      expect(cats, isNotEmpty);
      final ids = cats.map((c) => c['id']).toList();
      expect(ids, contains('salon'));
      expect(ids, contains('chambre'));
    });
  });

  group('DataService – Pièces et Panoramas', () {
    setUp(() => DataService.clearCache());

    test('getRoomsForProperty() retourne les pièces du bien 001', () async {
      final rooms = await DataService.getRoomsForProperty('prop_001');
      expect(rooms, isNotEmpty);
      expect(rooms.length, greaterThanOrEqualTo(4));
    });

    test('chaque pièce a un panorama défini', () async {
      final rooms = await DataService.getRoomsForProperty('prop_001');
      for (final r in rooms) {
        expect(r.containsKey('panorama'), isTrue);
        expect(r['panorama'], isNotEmpty);
      }
    });

    test('les hotspots ont des coordonnées valides (0.0 – 1.0)', () async {
      final rooms = await DataService.getRoomsForProperty('prop_001');
      for (final r in rooms) {
        final hotspots =
            List<Map<String, dynamic>>.from(r['hotspots'] as List);
        for (final h in hotspots) {
          final x = (h['x'] as num).toDouble();
          final y = (h['y'] as num).toDouble();
          expect(x, inInclusiveRange(0.0, 1.0));
          expect(y, inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('getRoomsForProperty() retourne vide pour un ID inexistant',
        () async {
      final rooms = await DataService.getRoomsForProperty('id_faux');
      expect(rooms, isEmpty);
    });
  });

  group('DataService – Recherche', () {
    setUp(() => DataService.clearCache());

    test('searchProperties() trouve un bien par ville', () async {
      final results = await DataService.searchProperties('Paris');
      expect(results, isNotEmpty);
      for (final r in results) {
        final loc = (r['localisation'] as String).toLowerCase();
        final adr = (r['adresse'] as String).toLowerCase();
        expect(loc.contains('paris') || adr.contains('paris'), isTrue);
      }
    });

    test('searchProperties() retourne vide pour une recherche sans résultat',
        () async {
      final results = await DataService.searchProperties('xyzinexistant999');
      expect(results, isEmpty);
    });

    test('searchProperties() est insensible à la casse', () async {
      final upper = await DataService.searchProperties('PARIS');
      final lower = await DataService.searchProperties('paris');
      expect(upper.length, equals(lower.length));
    });
  });
}
