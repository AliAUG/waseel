import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import 'package:waseel/core/network/dev_backend_override.dart';

class BackendConfig {
  const BackendConfig._();

  /// Backend base URL (APIs are under `/api`).
  ///
  /// **1.** Build/run: `--dart-define=WASEEL_API_BASE=http://HOST:3000/api`
  ///
  /// **2.** Or edit [kDevBackendBaseUrlOverride] in `dev_backend_override.dart` (same format).
  ///
  /// **3.** Otherwise:
  /// - **Web:** `http://<same host as the page>:3000/api` (`localhost` → `127.0.0.1`).
  /// - **Android emulator:** `http://10.0.2.2:3000/api`.
  /// - **Other (iOS simulator, macOS, Windows):** `http://127.0.0.1:3000/api`.
  static const String _fromEnv = String.fromEnvironment(
    'WASEEL_API_BASE',
    defaultValue: '',
  );

  static String get baseUrl {
    final fromEnv = _fromEnv.trim();
    if (fromEnv.isNotEmpty) return _stripTrailingSlashes(fromEnv);
    final fromFile = kDevBackendBaseUrlOverride.trim();
    if (fromFile.isNotEmpty) return _stripTrailingSlashes(fromFile);
    if (kIsWeb) {
      var host = Uri.base.host;
      if (host.isEmpty ||
          host == '0.0.0.0' ||
          host == '[::]' ||
          host == '::') {
        host = '127.0.0.1';
      } else if (host == 'localhost') {
        host = '127.0.0.1';
      }
      return 'http://$host:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  static String _stripTrailingSlashes(String s) {
    var out = s;
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  static const Duration requestTimeout = Duration(seconds: 20);
}
