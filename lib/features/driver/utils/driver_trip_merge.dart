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
    final pickupLatLng =
        pu is Map ? _extractLatLng(Map<String, dynamic>.from(pu)) : null;
    final dropoffLatLng =
        du is Map ? _extractLatLng(Map<String, dynamic>.from(du)) : null;
    return base.copyWith(
      passengerName: name,
      passengerRating: rating,
      pickupAddress: pickup,
      dropoffAddress: drop,
      estimatedFare: fare,
      pickupLatitude: pickupLatLng?.$1,
      pickupLongitude: pickupLatLng?.$2,
      dropoffLatitude: dropoffLatLng?.$1,
      dropoffLongitude: dropoffLatLng?.$2,
    );
  }

  static (double, double)? _extractLatLng(Map<String, dynamic> map) {
    final lat = _toDoubleNullable(map['latitude']);
    final lng = _toDoubleNullable(map['longitude']);
    if (lat != null && lng != null) return (lat, lng);

    final coordinates = map['coordinates'];
    if (coordinates is List && coordinates.length >= 2) {
      final coordLng = _toDoubleNullable(coordinates[0]);
      final coordLat = _toDoubleNullable(coordinates[1]);
      if (coordLat != null && coordLng != null) return (coordLat, coordLng);
    }
    return null;
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

  static double? _toDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
