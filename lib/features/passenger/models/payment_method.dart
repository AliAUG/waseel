/// Saved payment method (card)
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  final String id;
  final String type; // Visa, Mastercard, etc.
  final String lastFour;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  String get displayName => '$type **** $lastFour';
  String get expiry => '${expiryMonth.toString().padLeft(2, '0')}/$expiryYear';

  /// From `GET /wallet/payment-methods` item (`type`: `card`).
  factory PaymentMethod.fromBackend(Map<String, dynamic> json) {
    final id = _parseMongoId(json['_id']) ?? '';
    final cardType = json['cardType']?.toString() ?? 'Card';
    final displayType = cardType == 'Other' ? 'Card' : cardType;
    final rawFour = json['lastFourDigits']?.toString() ?? '';
    final lastFour = rawFour.length >= 4
        ? rawFour.substring(rawFour.length - 4)
        : rawFour.padLeft(4, '0');
    final expM = _toInt(json['expiryMonth'], fallback: 1).clamp(1, 12);
    final expYRaw = _toInt(json['expiryYear'], fallback: 0);
    final expY = expYRaw > 1000 ? expYRaw % 100 : expYRaw;
    return PaymentMethod(
      id: id,
      type: displayType,
      lastFour: lastFour,
      expiryMonth: expM,
      expiryYear: expY,
      isDefault: json['isDefault'] == true,
    );
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }
}
