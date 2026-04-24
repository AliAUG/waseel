import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class BackendConfig {
  const BackendConfig._();

  /// Backend base URL (APIs are under `/api`).
  ///
  /// Override at build/run time, e.g.:
  /// `flutter run --dart-define=WASEEL_API_BASE=http://192.168.1.10:3000/api`
  ///
  /// - Web / Windows / iOS simulator: default `localhost` is fine.
  /// - **Android emulator:** default is `http://10.0.2.2:3000/api` (maps to host PC).
  /// - **Physical Android phone:** set `WASEEL_API_BASE` to your PC LAN IP, e.g.
  ///   `http://192.168.x.x:3000/api`.
  static const String _fromEnv = String.fromEnvironment(
    'WASEEL_API_BASE',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://172.20.10.3:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const Duration requestTimeout = Duration(seconds: 20);
}
