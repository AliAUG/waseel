import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class UserApiService {
  UserApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Authenticated `GET /users/settings`.
  Future<Map<String, dynamic>?> getSettings(String token) async {
    final res = await _client.get(BackendEndpoints.settings, token: token);
    final data = res['data'];
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Authenticated `PUT /users/settings` — partial update (only send keys you change).
  Future<Map<String, dynamic>> updateSettings(
    String token,
    Map<String, dynamic> body,
  ) {
    return _client.put(
      BackendEndpoints.settings,
      token: token,
      body: body,
    );
  }

  /// Authenticated `PUT /users/profile` — [fullName] required; [email] optional if non-empty.
  Future<Map<String, dynamic>> updateProfile(
    String token, {
    required String fullName,
    String? email,
    String? profilePicture,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName,
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (profilePicture != null && profilePicture.trim().isNotEmpty)
        'profilePicture': profilePicture.trim(),
    };
    return _client.put(
      BackendEndpoints.userProfile,
      token: token,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> getSavedPlaces(String token) async {
    final res = await _client.get(BackendEndpoints.savedPlaces, token: token);
    final raw = res['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> addSavedPlace(
    String token, {
    required String label,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final res = await _client.post(
      BackendEndpoints.savedPlaces,
      token: token,
      body: <String, dynamic>{
        'label': label,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    final data = res['data'];
    if (data is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateSavedPlace(
    String token,
    String placeId, {
    required String label,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final res = await _client.put(
      BackendEndpoints.savedPlaceById(placeId),
      token: token,
      body: <String, dynamic>{
        'label': label,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    final data = res['data'];
    if (data is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteSavedPlace(String token, String placeId) async {
    await _client.delete(
      BackendEndpoints.savedPlaceById(placeId),
      token: token,
    );
  }
}
