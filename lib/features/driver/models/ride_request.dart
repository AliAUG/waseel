/// Incoming ride request from passenger
class RideRequest {
  const RideRequest({
    required this.passengerName,
    required this.passengerRating,
    required this.passengerTrips,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.estimatedFare,
    this.fareCurrency = 'USD',
    this.timeRemainingSeconds = 20,
    this.apiRequestId,
    this.tripId,
  });

  final String passengerName;
  final double passengerRating;
  final int passengerTrips;
  final String pickupAddress;
  final String dropoffAddress;
  final double estimatedFare;
  /// Trip fare currency from API (e.g. `USD`, `LBP`).
  final String fareCurrency;
  final int timeRemainingSeconds;

  /// Set when request comes from `GET /driver/ride-requests` (accept/decline use this id).
  final String? apiRequestId;

  /// Trip document id after accept or from pending request’s `trip` ref.
  final String? tripId;

  RideRequest copyWith({
    String? passengerName,
    double? passengerRating,
    int? passengerTrips,
    String? pickupAddress,
    String? dropoffAddress,
    double? estimatedFare,
    String? fareCurrency,
    int? timeRemainingSeconds,
    String? apiRequestId,
    String? tripId,
  }) {
    return RideRequest(
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      passengerTrips: passengerTrips ?? this.passengerTrips,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      fareCurrency: fareCurrency ?? this.fareCurrency,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      apiRequestId: apiRequestId ?? this.apiRequestId,
      tripId: tripId ?? this.tripId,
    );
  }
}
