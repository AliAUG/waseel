import 'package:flutter/material.dart';

enum RideCategory { economy, comfort, luxury }

class RideType {
  const RideType({
    required this.category,
    required this.icon,
    required this.color,
    required this.eta,
    required this.price,
    required this.illustrationAsset,
    this.backendId,
  });

  final RideCategory category;
  final IconData icon;
  final Color color;
  /// Home list car image.
  final String illustrationAsset;
  final String eta;
  final String price;
  /// MongoDB id from `GET /trips/ride-types` (for `createTrip` later).
  final String? backendId;

  String get label {
    switch (category) {
      case RideCategory.economy:
        return 'Economy';
      case RideCategory.comfort:
        return 'Comfort';
      case RideCategory.luxury:
        return 'Luxury';
    }
  }

  /// Arabic subtitle for home ride list.
  String get arabicLabel {
    switch (category) {
      case RideCategory.economy:
        return 'ركوب اقتصادي';
      case RideCategory.comfort:
        return 'ركوب مريح';
      case RideCategory.luxury:
        return 'ركوب فخم';
    }
  }

  String get englishRideTitle => '$label Ride';

  /// Localized ETA line (e.g. `3 min away` → Arabic approx.).
  String etaForLocale(bool arabic) {
    if (!arabic) return eta;
    final m = RegExp(r'(\d+)\s*min').firstMatch(eta);
    if (m != null) return 'بعد حوالي ${m.group(1)} د';
    return eta;
  }

  static const economy = RideType(
    category: RideCategory.economy,
    icon: Icons.directions_car,
    color: Color(0xFFE53935),
    eta: '3 min away',
    price: '30,000 L.L',
    illustrationAsset: 'assets/images/ride_economy.png',
    backendId: null,
  );

  static const comfort = RideType(
    category: RideCategory.comfort,
    icon: Icons.directions_car,
    color: Color(0xFF2196F3),
    eta: '5 min away',
    price: '60,000 L.L',
    illustrationAsset: 'assets/images/ride_comfort.png',
    backendId: null,
  );

  static const luxury = RideType(
    category: RideCategory.luxury,
    icon: Icons.directions_car,
    color: Color(0xFF9C27B0),
    eta: '8 min away',
    price: '80,000 L.L',
    illustrationAsset: 'assets/images/ride_luxury.png',
    backendId: null,
  );

  static const List<RideType> all = [economy, comfort, luxury];

  /// Order shown on home (vertical list: Economy → Comfort → Luxury).
  static const List<RideType> homeDisplayOrder = [economy, comfort, luxury];

  /// Builds from one item of `GET /api/trips/ride-types` (`data` array).
  factory RideType.fromBackendJson(Map<String, dynamic> json) {
    final name = json['name']?.toString().trim() ?? '';
    final category = _categoryFromBackendName(name);
    final basePrice = _parseInt(json['basePrice'], 0);
    final mins = _parseInt(json['timeEstimateMinutes'], 5);
    final rawCur = json['currency']?.toString().trim();
    final currency =
        (rawCur == null || rawCur.isEmpty) ? 'LBP' : rawCur;
    final priceLabel = currency == 'LBP'
        ? '${_formatThousands(basePrice)} L.L'
        : '$basePrice $currency';
    return RideType(
      category: category,
      icon: Icons.directions_car,
      color: _colorForCategory(category),
      eta: '$mins min away',
      price: priceLabel,
      illustrationAsset: _illustrationForCategory(category),
      backendId: _parseMongoId(json['_id']),
    );
  }

  static RideCategory _categoryFromBackendName(String name) {
    switch (name.toLowerCase()) {
      case 'comfort':
        return RideCategory.comfort;
      case 'luxury':
        return RideCategory.luxury;
      case 'economy':
      default:
        return RideCategory.economy;
    }
  }

  static Color _colorForCategory(RideCategory c) {
    switch (c) {
      case RideCategory.economy:
        return const Color(0xFFE53935);
      case RideCategory.comfort:
        return const Color(0xFF2196F3);
      case RideCategory.luxury:
        return const Color(0xFF9C27B0);
    }
  }

  static String _illustrationForCategory(RideCategory c) {
    switch (c) {
      case RideCategory.economy:
        return 'assets/images/ride_economy.png';
      case RideCategory.comfort:
        return 'assets/images/ride_comfort.png';
      case RideCategory.luxury:
        return 'assets/images/ride_luxury.png';
    }
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static String _formatThousands(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }
}
