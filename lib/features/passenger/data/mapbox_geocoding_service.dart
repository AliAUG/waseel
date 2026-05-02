import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waseel/core/mapbox_env.dart';
import 'package:waseel/features/passenger/models/location_data.dart';

class MapboxGeocodingService {
  MapboxGeocodingService({String? accessToken})
      : accessToken = accessToken ?? MapboxEnv.accessToken;

  final String accessToken;

  bool get hasToken => accessToken.trim().isNotEmpty;

  Future<List<LocationData>> searchPlaces(String query) async {
    final trimmed = query.trim();

    if (trimmed.length < 2 || !hasToken) {
      return [];
    }

    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/${Uri.encodeComponent(trimmed)}.json',
      {
        'access_token': accessToken,
        'autocomplete': 'true',
        'limit': '8',
        'country': 'LB',
        'language': 'en',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not search locations');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'];

    if (features is! List) {
      return [];
    }

    return features
        .whereType<Map<String, dynamic>>()
        .map((feature) {
          final center = feature['center'];
          final placeName = feature['place_name'];

          if (center is! List || center.length < 2 || placeName == null) {
            return null;
          }

          final lng = (center[0] as num).toDouble();
          final lat = (center[1] as num).toDouble();

          return LocationData(
            lat: lat,
            lng: lng,
            address: placeName.toString(),
          );
        })
        .whereType<LocationData>()
        .toList();
  }

  Future<LocationData?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    if (!hasToken) return null;

    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$lng,$lat.json',
      {
        'access_token': accessToken,
        'limit': '1',
        'language': 'en',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'];

    if (features is! List || features.isEmpty) {
      return null;
    }

    final first = features.first;

    if (first is! Map<String, dynamic>) {
      return null;
    }

    final placeName = first['place_name'];

    return LocationData(
      lat: lat,
      lng: lng,
      address: placeName?.toString() ?? 'Current location',
    );
  }
}
