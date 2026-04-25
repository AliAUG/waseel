import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class WalletApiService {
  WalletApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Authenticated `GET /wallet` — returns wallet doc (`balance`, `currency`, …).
  Future<Map<String, dynamic>> getWallet(String token) async {
    final res = await _client.get(BackendEndpoints.wallet, token: token);
    final data = res['data'];
    if (data is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(data);
  }

  /// Authenticated `GET /wallet/transactions` — items + `total`, `page`, `totalPages`.
  Future<({
    List<Map<String, dynamic>> items,
    int total,
    int page,
    int totalPages,
  })> getTransactionsWithMeta(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final path =
        '${BackendEndpoints.walletTransactions}?page=$page&limit=$limit';
    final res = await _client.get(path, token: token);
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
    final raw = map['transactions'];
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

  /// Authenticated `GET /wallet/transactions?page=&limit=`.
  Future<List<Map<String, dynamic>>> getTransactions(
    String token, {
    int page = 1,
    int limit = 30,
  }) async {
    final r = await getTransactionsWithMeta(token, page: page, limit: limit);
    return r.items;
  }

  /// Authenticated `POST /wallet/add-balance` — body: `amount`, optional `paymentMethod`.
  Future<Map<String, dynamic>> addBalance(
    String token, {
    required int amount,
    String? paymentMethod,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'paymentMethod': paymentMethod,
    };
    final res = await _client.post(
      BackendEndpoints.walletAddBalance,
      body: body,
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return {};
    return Map<String, dynamic>.from(data);
  }

  /// Authenticated `GET /wallet/payment-methods` — `{ methods, walletBalance }`.
  Future<Map<String, dynamic>> getPaymentMethods(String token) async {
    final res = await _client.get(
      BackendEndpoints.walletPaymentMethods,
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return {};
    return Map<String, dynamic>.from(data);
  }

  /// Authenticated `PUT /wallet/payment-methods/:id/default`.
  Future<void> setDefaultPaymentMethod(String token, String id) async {
    await _client.put(
      BackendEndpoints.walletPaymentMethodSetDefault(id),
      token: token,
    );
  }

  /// Authenticated `POST /wallet/payment-methods` — saves a card (`type`: `card`).
  Future<Map<String, dynamic>> addPaymentMethod(
    String token, {
    required String cardType,
    required String lastFourDigits,
    required int expiryMonth,
    required int expiryYear,
  }) async {
    final res = await _client.post(
      BackendEndpoints.walletPaymentMethods,
      body: {
        'type': 'card',
        'cardType': cardType,
        'lastFourDigits': lastFourDigits,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
      },
      token: token,
    );
    final data = res['data'];
    if (data is! Map) return {};
    return Map<String, dynamic>.from(data);
  }
}
