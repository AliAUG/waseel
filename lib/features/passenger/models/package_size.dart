enum PackageSize { small, medium, large }

extension PackageSizeX on PackageSize {
  String get label {
    switch (this) {
      case PackageSize.small:
        return 'Small';
      case PackageSize.medium:
        return 'Medium';
      case PackageSize.large:
        return 'Large';
    }
  }

  String get weight {
    switch (this) {
      case PackageSize.small:
        return 'Up to 5kg';
      case PackageSize.medium:
        return 'Up to 15kg';
      case PackageSize.large:
        return 'Up to 30kg';
    }
  }

  /// Multiplier for delivery fee (smaller = cheaper)
  double get feeMultiplier {
    switch (this) {
      case PackageSize.small:
        return 1.0;
      case PackageSize.medium:
        return 1.5;
      case PackageSize.large:
        return 2.0;
    }
  }
}

/// Estimated delivery window label for a package size and distance (e.g. `25–35 min`).
String deliveryEtaRange(
  PackageSize size,
  double distanceKm, {
  bool arabic = false,
}) {
  final baseMin = 20 + size.index * 5 + (distanceKm * 2).round();
  final hi = baseMin + 10;
  if (arabic) return '$baseMin–$hi دقيقة';
  return '$baseMin–$hi min';
}

/// Calculates delivery fee in L.L based on package size and distance (km)
int calculateDeliveryFee(PackageSize size, double distanceKm) {
  const int baseFee = 5000; // 5,000 L.L base
  const int perKmFee = 2000; // 2,000 L.L per km
  final distanceFee = baseFee + (distanceKm * perKmFee).round();
  return (distanceFee * size.feeMultiplier).round();
}

String formatLebanesePounds(int amount) {
  final s = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return '$buffer L.L';
}

/// For wallet transactions: shows + or - prefix
String formatSignedLebanesePounds(int amount) {
  final formatted = formatLebanesePounds(amount.abs());
  if (amount < 0) return '-$formatted';
  if (amount > 0) return '+$formatted';
  return formatted;
}
