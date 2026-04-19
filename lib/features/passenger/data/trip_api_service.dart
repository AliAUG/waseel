import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';
import 'package:waseel/features/passenger/models/ride_type.dart';
import 'package:waseel/features/passenger/models/trip_history.dart';

class TripApiService {
  TripApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Public `GET /trips/ride-types` — no auth.
  Future<List<RideType>> getRideTypes() async {
    final res = await _client.get(BackendEndpoints.rideTypes);
    final raw = res['data'];
    if (raw is! List) return [];
    final out = <RideType>[];
    for (final item in raw) {
      if (item is! Map) continue;
      out.add(RideType.fromBackendJson(Map<String, dynamic>.from(item)));
    }
    return out;
  }

  /// Authenticated `POST /trips` — [rideTypeId] is MongoDB id from ride-types.
  Future<Map<String, dynamic>> createTrip({
    required String token,
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> dropoffLocation,
    required String rideTypeId,
    String paymentMethod = 'cash',
    double distanceKm = 0,
    int timeMinutes = 0,
    String currency = 'LBP',
  }) {
    return _client.post(
      BackendEndpoints.trips,
      token: token,
      body: <String, dynamic>{
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
        'rideType': rideTypeId,
        'paymentMethod': paymentMethod,
        'distanceKm': distanceKm,
        'timeMinutes': timeMinutes,
        'currency': currency,
      },
    );
  }

  /// Authenticated `POST /deliveries` — creates a delivery in `searching` status.
  /// Returns Mongo id string, or null if response has no id.
  Future<String?> createDelivery({
    required String token,
    required String pickupAddress,
    required String dropoffAddress,
    required String packageSizeLabel,
    required String weightLimit,
    required int deliveryFee,
    required int etaMinMinutes,
    required int etaMaxMinutes,
    String? specialInstructions,
  }) async {
    final packageDetails = <String, dynamic>{
      'size': packageSizeLabel,
      'weightLimit': weightLimit,
    };
    final notes = specialInstructions?.trim();
    if (notes != null && notes.isNotEmpty) {
      packageDetails['specialInstructions'] = notes;
    }
    final res = await _client.post(
      BackendEndpoints.deliveries,
      token: token,
      body: <String, dynamic>{
        'pickupLocation': {'address': pickupAddress},
        'dropoffLocation': {'address': dropoffAddress},
        'packageDetails': packageDetails,
        'estimatedDeliveryTimeMinutes': <String, dynamic>{
          'min': etaMinMinutes,
          'max': etaMaxMinutes,
        },
        'deliveryFee': deliveryFee,
        'currency': 'LBP',
      },
    );
    final data = res['data'];
    if (data is! Map) return null;
    final m = Map<String, dynamic>.from(data);
    final id = m['_id'];
    if (id is String && id.isNotEmpty) return id;
    if (id is Map && id[r'$oid'] != null) {
      return id[r'$oid'].toString();
    }
    return null;
  }

  /// Authenticated `GET /trips?page=&limit=` — trip history for passenger.
  Future<List<TripHistory>> getTripHistory(
    String token, {
    int page = 1,
    int limit = 30,
  }) async {
    final path =
        '${BackendEndpoints.trips}?page=$page&limit=$limit';
    final res = await _client.get(path, token: token);
    final data = res['data'];
    if (data is! Map) return [];
    final raw = data['trips'];
    if (raw is! List) return [];
    final out = <TripHistory>[];
    for (final item in raw) {
      if (item is! Map) continue;
      out.add(TripHistory.fromBackend(Map<String, dynamic>.from(item)));
    }
    return out;
  }

  /// Authenticated `GET /history?type=deliveries&page=&limit=`.
  Future<List<TripHistory>> getDeliveryHistory(
    String token, {
    int page = 1,
    int limit = 30,
  }) async {
    final path =
        '${BackendEndpoints.history}?type=deliveries&page=$page&limit=$limit';
    final res = await _client.get(path, token: token);
    final data = res['data'];
    if (data is! Map) return [];
    final raw = data['items'];
    if (raw is! List) return [];
    final out = <TripHistory>[];
    for (final item in raw) {
      if (item is! Map) continue;
      out.add(TripHistory.fromDeliveryJson(Map<String, dynamic>.from(item)));
    }
    return out;
  }

  /// Authenticated `GET /history/deliveries/:id`.
  Future<TripHistory?> getHistoryDeliveryDetails(
    String token,
    String deliveryId,
  ) async {
    if (deliveryId.isEmpty) return null;
    final res = await _client.get(
      BackendEndpoints.historyDeliveryDetails(deliveryId),
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return null;
    return TripHistory.fromDeliveryJson(Map<String, dynamic>.from(data));
  }

  /// Authenticated `GET /trips/:id/details` — full trip + driver + vehicle.
  Future<TripHistory?> getTripDetails(String token, String tripId) async {
    if (tripId.isEmpty) return null;
    final res = await _client.get(
      BackendEndpoints.tripDetails(tripId),
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return null;
    return TripHistory.fromBackend(Map<String, dynamic>.from(data));
  }

  /// Authenticated `POST /trips/:id/rate` — trip must be `completed` on server.
  Future<Map<String, dynamic>> rateTrip({
    required String token,
    required String tripId,
    required int stars,
    String? comment,
    List<String>? feedbackTags,
  }) {
    return _client.post(
      BackendEndpoints.tripRate(tripId),
      token: token,
      body: <String, dynamic>{
        'stars': stars.clamp(1, 5),
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
        if (feedbackTags != null && feedbackTags.isNotEmpty)
          'feedbackTags': feedbackTags,
      },
    );
  }

  /// Authenticated `POST /deliveries/complete` — sets status `completed`.
  Future<void> completeDelivery({
    required String token,
    required String deliveryId,
  }) async {
    await _client.post(
      BackendEndpoints.deliveryComplete,
      token: token,
      body: <String, dynamic>{'deliveryId': deliveryId},
    );
  }

  /// Authenticated `POST /deliveries/:id/rate` — delivery must be `completed`.
  Future<Map<String, dynamic>> rateDelivery({
    required String token,
    required String deliveryId,
    required int stars,
    String? comment,
    List<String>? feedbackTags,
  }) {
    return _client.post(
      BackendEndpoints.deliveryRate(deliveryId),
      token: token,
      body: <String, dynamic>{
        'stars': stars.clamp(1, 5),
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
        if (feedbackTags != null && feedbackTags.isNotEmpty)
          'feedbackTags': feedbackTags,
      },
    );
  }
}
