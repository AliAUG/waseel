import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class BackendConfig {
  const BackendConfig._();

  static const String _fromEnv = String.fromEnvironment(
    'WASEEL_API_BASE',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;

    if (kIsWeb) return 'http://localhost:3000/api';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://172.20.10.5:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static const Duration requestTimeout = Duration(seconds: 20);
}