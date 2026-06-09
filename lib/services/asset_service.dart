import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// AssetService – Dev5
/// Centralise le chargement et l'affichage des images/assets.
class AssetService {
  // ── Chemins des assets locaux ─────────────────────────────────────────────
  static const String imagesPath = 'assets/images/';
  static const String panoramasPath = 'assets/panoramas/';
  static const String models3dPath = 'assets/models_3d/';
  static const String iconsPath = 'assets/icons/';

  // ── Images par défaut (fallback) ──────────────────────────────────────────
  static const String defaultProperty =
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800';
  static const String defaultFurniture =
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800';
  static const String defaultPanorama =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Pano_0002.jpg/1280px-Pano_0002.jpg';

  // ── Images réseau des biens (données de démo) ─────────────────────────────
  static const Map<String, String> propertyNetworkImages = {
    'prop_001':
        'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800',
    'prop_002':
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
    'prop_003':
        'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800',
  };

  // ── URLs panoramas 360° (données de démo) ────────────────────────────────
  static const Map<String, String> panoramaUrls = {
    'panorama_salon':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Pano_0002.jpg/1280px-Pano_0002.jpg',
    'panorama_cuisine':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/2017_Oban_360_image_1.jpg/1280px-2017_Oban_360_image_1.jpg',
    'panorama_chambre':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Pano_0002.jpg/1280px-Pano_0002.jpg',
    'panorama_sdb':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Pano_0002.jpg/1280px-Pano_0002.jpg',
  };

  /// Retourne un widget image avec fallback automatique.
  static Widget networkImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: const Color(0xFFF5F0E8),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFC9A84C),
              ),
            ),
          ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF5F0E8),
        child: const Icon(
          Icons.home_outlined,
          color: Color(0xFFC9A84C),
          size: 40,
        ),
      ),
    );
  }

  /// Retourne l'URL réseau d'un bien par son ID.
  static String getPropertyImageUrl(String propertyId) {
    return propertyNetworkImages[propertyId] ?? defaultProperty;
  }

  /// Retourne l'URL d'un panorama par son nom.
  static String getPanoramaUrl(String panoramaName) {
    return panoramaUrls[panoramaName] ?? defaultPanorama;
  }

  /// Formatte un prix en euros avec espaces (ex: 425 000 €).
  static String formatPrice(dynamic price) {
    final p = (price is double) ? price.toInt() : (price as int);
    final str = p.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
      count++;
    }
    return '${buffer.toString().split('').reversed.join()} €';
  }

  /// Formatte une surface (ex: 75 m²).
  static String formatSurface(dynamic surface) {
    return '${surface.toInt()} m²';
  }
}
