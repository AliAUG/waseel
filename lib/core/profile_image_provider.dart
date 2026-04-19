import 'dart:io';

import 'package:flutter/painting.dart';

/// [pathOrUrl] is a local file path or `http(s)` URL from `GET /auth/profile` / `PUT /users/profile`.
ImageProvider? profileImageProvider(String? pathOrUrl) {
  final s = pathOrUrl?.trim();
  if (s == null || s.isEmpty) return null;
  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return NetworkImage(s);
  }
  final f = File(s);
  if (f.existsSync()) return FileImage(f);
  return null;
}
