/// Represents a wallet transaction (top-up, trip, delivery, refund)
enum TransactionType {
  trip,
  topUp,
  delivery,
  refund,
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    required this.amount,
  });

  final String id;
  final TransactionType type;
  final String description;
  final DateTime date;
  /// Positive for credit (top-up, refund), negative for debit (trip, delivery)
  final int amount;

  bool get isCredit => amount > 0;

  /// From `GET /wallet/transactions` item (`type` matches backend enum).
  factory WalletTransaction.fromBackend(Map<String, dynamic> json) {
    final id = _parseMongoId(json['_id']) ??
        json['transactionId']?.toString() ??
        '';
    final typeStr = json['type']?.toString() ?? '';
    final type = _transactionTypeFromBackend(typeStr);
    final rawDesc = json['description']?.toString().trim();
    final description = (rawDesc != null && rawDesc.isNotEmpty)
        ? rawDesc
        : _defaultDescription(typeStr);
    final date = _parseDate(json['createdAt']);
    final amount = _signedAmountFromBackend(typeStr, json['amount']);
    return WalletTransaction(
      id: id,
      type: type,
      description: description,
      date: date,
      amount: amount,
    );
  }

  static TransactionType _transactionTypeFromBackend(String typeStr) {
    switch (typeStr) {
      case 'wallet_topup':
        return TransactionType.topUp;
      case 'package_delivery':
        return TransactionType.delivery;
      case 'refund':
      case 'earning':
        return TransactionType.refund;
      case 'trip':
      case 'withdrawal':
      default:
        return TransactionType.trip;
    }
  }

  static String _defaultDescription(String typeStr) {
    switch (typeStr) {
      case 'wallet_topup':
        return 'Wallet top-up';
      case 'package_delivery':
        return 'Package delivery';
      case 'refund':
        return 'Refund';
      case 'withdrawal':
        return 'Withdrawal';
      case 'earning':
        return 'Earning';
      case 'trip':
        return 'Trip';
      default:
        return 'Transaction';
    }
  }

  /// Backend amounts are usually positive; debit types show as negative in UI.
  static int _signedAmountFromBackend(String typeStr, dynamic raw) {
    final v = _toInt(raw);
    const debitTypes = {'trip', 'package_delivery', 'withdrawal'};
    if (debitTypes.contains(typeStr)) {
      return -v.abs();
    }
    return v.abs();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    if (v is Map) {
      final d = v[r'$date'];
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
    }
    return DateTime.now();
  }
}
