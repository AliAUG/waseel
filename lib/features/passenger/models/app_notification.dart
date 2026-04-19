import 'package:flutter/material.dart';

/// In-app notification from `GET /notifications`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    this.icon,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String category;
  final String title;
  final String message;
  final String? icon;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromBackend(Map<String, dynamic> json) {
    final id = _parseId(json['_id']) ?? '';
    return AppNotification(
      id: id,
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? 'System',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      icon: json['icon']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? category,
    String? title,
    String? message,
    String? icon,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'document':
        return Icons.description_outlined;
      case 'money':
        return Icons.payments_outlined;
      case 'package':
        return Icons.inventory_2_outlined;
      case 'car':
      default:
        return Icons.directions_car_outlined;
    }
  }

  static String? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    if (v is Map) {
      final d = v[r'$date'];
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
    }
    return DateTime.now();
  }
}
