import 'package:waseel/features/driver/models/ride_request.dart';

/// Maps `GET /driver/trips/:id` JSON into UI [RideRequest] fields.
class DriverTripMerge {
  DriverTripMerge._();

  /// Prefer `actualFare`, then `estimatedFare`, else [fallback].
  static int fareLbpFromTripMap(Map<String, dynamic> m, int fallback) {
    final a = m['actualFare'];
    final e = m['estimatedFare'];
    if (a != null) return _toInt(a);
    if (e != null) return _toInt(e);
    return fallback;
  }

  static RideRequest mergeTripMapIntoRide(
    RideRequest base,
    Map<String, dynamic> trip,
  ) {
    var name = base.passengerName;
    var rating = base.passengerRating;
    final p = trip['passenger'];
    if (p is Map) {
      final fn = p['fullName']?.toString();
      if (fn != null && fn.isNotEmpty) name = fn;
      final r = p['rating'];
      if (r != null) {
        rating = _toDouble(r, rating);
      }
    }
    final pu = trip['pickupLocation'];
    final du = trip['dropoffLocation'];
    final pickup = pu is Map
        ? (pu['address']?.toString() ?? base.pickupAddress)
        : base.pickupAddress;
    final drop = du is Map
        ? (du['address']?.toString() ?? base.dropoffAddress)
        : base.dropoffAddress;
    final fare = fareLbpFromTripMap(trip, base.estimatedFare);
    return base.copyWith(
      passengerName: name,
      passengerRating: rating,
      pickupAddress: pickup,
      dropoffAddress: drop,
      estimatedFare: fare,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}
