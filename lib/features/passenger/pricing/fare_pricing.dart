import 'package:waseel/features/passenger/models/package_size.dart';

/// Passenger-facing fares (USD). Ride: $1/km. Delivery: $1/kg (billing weight from [PackageSize]).
const double kUsdPerKmRide = 1.0;
const double kUsdPerKgDelivery = 1.0;

/// Shown on home before pickup/destination exist.
const double kDefaultRidePreviewDistanceKm = 5.0;

double rideFareUsd(double distanceKm) {
  final raw = distanceKm * kUsdPerKmRide;
  return (raw * 100).round() / 100;
}

String formatUsd(num amount) {
  final v = amount < 0 ? 0.0 : amount.toDouble();
  if (v == v.roundToDouble()) return '\$${v.round()}';
  return '\$${v.toStringAsFixed(2)}';
}

/// Delivery total from weight only ($/kg), per product spec.
double calculateDeliveryFareUsd(PackageSize size) {
  return (size.billingWeightKg * kUsdPerKgDelivery * 100).round() / 100;
}

String formatDriverTripFare(double amount, String currency) {
  final c = currency.toUpperCase();
  if (c == 'LBP') {
    final s = amount.abs().round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf L.L';
  }
  return formatUsd(amount);
}
