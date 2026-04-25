import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class NotificationApiService {
  NotificationApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// `GET /notifications?page=&limit=&category=` — `category` omitted when `All`.
  Future<({
    List<Map<String, dynamic>> items,
    int total,
    int page,
    int totalPages,
  })> getNotifications(
    String token, {
    int page = 1,
    int limit = 20,
    String category = 'All',
  }) async {
    final qp = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (category.isNotEmpty && category != 'All') {
      qp['category'] = category;
    }
    final q = qp.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _client.get(
      '${BackendEndpoints.notifications}?$q',
      token: token,
    );
    final data = res['data'];
    if (data is! Map) {
      return (
        items: <Map<String, dynamic>>[],
        total: 0,
        page: page,
        totalPages: 0,
      );
    }
    final map = Map<String, dynamic>.from(data);
    final raw = map['notifications'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.round();
      return int.tryParse(v.toString()) ?? fallback;
    }

    return (
      items: items,
      total: toInt(map['total']),
      page: toInt(map['page'], page),
      totalPages: toInt(map['totalPages']),
    );
  }

  Future<void> markAsRead(String token, String id) async {
    await _client.put(
      BackendEndpoints.notificationMarkRead(id),
      token: token,
    );
  }

  Future<void> markAllAsRead(String token) async {
    await _client.put(
      BackendEndpoints.notificationsReadAll,
      token: token,
    );
  }
}
