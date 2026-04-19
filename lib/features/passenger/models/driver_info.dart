import 'package:waseel/features/passenger/models/trip_history.dart';

/// Driver info - populated from API when a driver is assigned, never hardcoded
class DriverInfo {
  const DriverInfo({
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.location,
  });

  final String name;
  final double rating;
  final String vehicle;
  final String location;

  /// Creates a placeholder when driver data is loading - replace with real API data
  factory DriverInfo.placeholder() => DriverInfo(
        name: 'Driver',
        rating: 0,
        vehicle: '—',
        location: 'Lebanon',
      );

  factory DriverInfo.fromTripHistory(TripHistory t) => DriverInfo(
        name: t.driverName,
        rating: t.driverRating,
        vehicle: t.vehicle,
        location: t.driverLocation,
      );
}
