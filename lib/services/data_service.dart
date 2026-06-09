import 'dart:convert';
import 'package:flutter/services.dart';

/// DataService – Dev5
/// Charge et parse les données locales JSON des biens et meubles.
class DataService {
  static const String _dataPath = 'assets/data/immospace_data.json';
  static Map<String, dynamic>? _cache;

  // ── Charge une seule fois, met en cache ───────────────────────────────────
  static Future<Map<String, dynamic>> _loadData() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_dataPath);
    _cache = json.decode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  // ── Biens immobiliers ─────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getProperties() async {
    final data = await _loadData();
    return List<Map<String, dynamic>>.from(data['properties'] as List);
  }

  static Future<Map<String, dynamic>?> getPropertyById(String id) async {
    final properties = await getProperties();
    try {
      return properties.firstWhere((p) => p['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ── Meubles ───────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getFurniture() async {
    final data = await _loadData();
    return List<Map<String, dynamic>>.from(data['meubles'] as List);
  }

  static Future<List<Map<String, dynamic>>> getFurnitureByCategory(
      String category) async {
    final all = await getFurniture();
    return all.where((m) => m['categorie'] == category).toList();
  }

  static Future<List<Map<String, dynamic>>> getFurnitureCategories() async {
    final data = await _loadData();
    return List<Map<String, dynamic>>.from(
        data['categories_meubles'] as List);
  }

  // ── Pièces d'un bien ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getRoomsForProperty(
      String propertyId) async {
    final property = await getPropertyById(propertyId);
    if (property == null) return [];
    return List<Map<String, dynamic>>.from(
        property['pieces_detail'] as List);
  }

  // ── Recherche texte ───────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> searchProperties(
      String query) async {
    final all = await getProperties();
    final q = query.toLowerCase();
    return all.where((p) {
      return (p['localisation'] as String).toLowerCase().contains(q) ||
          (p['titre'] as String).toLowerCase().contains(q) ||
          (p['adresse'] as String).toLowerCase().contains(q);
    }).toList();
  }

  // ── Vide le cache (utile pour les tests) ──────────────────────────────────
  static void clearCache() => _cache = null;
}
