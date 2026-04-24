import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class DriverApiService {
  DriverApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> getDashboard(String token) async {
    final res = await _client.get(BackendEndpoints.driverDashboard, token: token);
    final data = res['data'];
    if (data is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> getRideRequests(String token) async {
    final res = await _client.get(BackendEndpoints.driverRequests, token: token);
    final data = res['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> getTripHistory(
    String token, {
    int page = 1,
    int limit = 30,
  }) async {
    final path =
        '${BackendEndpoints.driverTrips}?page=$page&limit=$limit';
    final res = await _client.get(path, token: token);
    final data = res['data'];
    if (data is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(data);
  }

  /// `GET /driver/trips/:id` — single trip (populated).
  Future<Map<String, dynamic>> getTrip(String token, String tripId) async {
    final res = await _client.get(
      BackendEndpoints.driverTripById(tripId),
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getWallet(String token) async {
    final res = await _client.get(BackendEndpoints.driverWallet, token: token);
    final data = res['data'];
    if (data is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getTransactions(
    String token, {
    int page = 1,
    int limit = 30,
    String? type,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final query = q.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final path = '${BackendEndpoints.driverTransactions}?$query';
    final res = await _client.get(path, token: token);
    final data = res['data'];
    if (data is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> acceptRideRequest(
    String token,
    String requestId,
  ) {
    return _client.post(
      BackendEndpoints.driverRideRequestAccept(requestId),
      token: token,
      body: <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> declineRideRequest(
    String token,
    String requestId,
  ) {
    return _client.post(
      BackendEndpoints.driverRideRequestDecline(requestId),
      token: token,
      body: <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> requestPayout(String token, int amount) {
    return _client.post(
      BackendEndpoints.driverPayout,
      token: token,
      body: <String, dynamic>{'amount': amount},
    );
  }

  Future<List<Map<String, dynamic>>> getDocuments(String token) async {
    final res = await _client.get(BackendEndpoints.driverDocuments, token: token);
    final data = res['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> uploadDocument(
    String token, {
    required String documentType,
    List<String> documentFiles = const <String>[],
  }) {
    return _client.post(
      BackendEndpoints.driverDocuments,
      token: token,
      body: <String, dynamic>{
        'documentType': documentType,
        'documentFiles': documentFiles,
      },
    );
  }

  /// Server: `driver_en_route` | `driver_arrived` | `en_route` | `completed` | …
  Future<Map<String, dynamic>> updateTripStatus(
    String token,
    String tripId,
    String status,
  ) {
    return _client.put(
      BackendEndpoints.driverTripStatus(tripId),
      token: token,
      body: <String, dynamic>{'status': status},
    );
  }
}
