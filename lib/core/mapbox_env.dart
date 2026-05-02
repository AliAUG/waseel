import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mapbox token: `.env` asset first, then `--dart-define=MAPBOX_ACCESS_TOKEN=...`.
abstract final class MapboxEnv {
  static String get accessToken {
    final fromFile = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    const fromDefine = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    if (fromDefine.isNotEmpty) return fromDefine.trim();
    return '';
  }

  static bool get hasAccessToken => accessToken.isNotEmpty;
}
