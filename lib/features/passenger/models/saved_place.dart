import 'package:flutter/material.dart';

/// Saved location (Home, Work, custom)
enum SavedPlaceType {
  home,
  work,
  gym,
  custom,
}

extension SavedPlaceTypeX on SavedPlaceType {
  String get label {
    switch (this) {
      case SavedPlaceType.home:
        return 'Home';
      case SavedPlaceType.work:
        return 'Work';
      case SavedPlaceType.gym:
        return 'Gym';
      case SavedPlaceType.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case SavedPlaceType.home:
        return Icons.home;
      case SavedPlaceType.work:
        return Icons.work;
      case SavedPlaceType.gym:
        return Icons.fitness_center;
      case SavedPlaceType.custom:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case SavedPlaceType.home:
        return Colors.green;
      case SavedPlaceType.work:
        return Colors.blue;
      case SavedPlaceType.gym:
        return Colors.purple;
      case SavedPlaceType.custom:
        return Colors.pink;
    }
  }
}

class SavedPlace {
  const SavedPlace({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
  });

  final String id;
  final SavedPlaceType type;
  final String name;
  final String address;

  /// From `GET/POST /users/saved-places` document (`label`, `address`, `_id`).
  factory SavedPlace.fromBackend(Map<String, dynamic> json) {
    final id = _parseMongoId(json['_id']) ?? '';
    final label = json['label']?.toString() ?? '';
    final address = json['address']?.toString() ?? '';
    return SavedPlace(
      id: id,
      type: savedPlaceTypeFromLabel(label),
      name: label.isEmpty ? 'Place' : label,
      address: address,
    );
  }

  static SavedPlaceType savedPlaceTypeFromLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'home':
        return SavedPlaceType.home;
      case 'work':
        return SavedPlaceType.work;
      case 'gym':
        return SavedPlaceType.gym;
      default:
        return SavedPlaceType.custom;
    }
  }

  static String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }
}
