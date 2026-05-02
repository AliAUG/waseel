/// Incoming ride request from passenger
class RideRequest {
  const RideRequest({
    required this.passengerName,
    required this.passengerRating,
    required this.passengerTrips,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.estimatedFare,
    this.timeRemainingSeconds = 20,
    this.apiRequestId,
    this.tripId,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.passengerLiveLatitude,
    this.passengerLiveLongitude,
    this.tripStatus,
  });

  final String passengerName;
  final double passengerRating;
  final int passengerTrips;
  final String pickupAddress;
  final String dropoffAddress;
  final int estimatedFare;
  final int timeRemainingSeconds;

  /// Set when request comes from `GET /driver/ride-requests` (accept/decline use this id).
  final String? apiRequestId;

  /// Trip document id after accept or from pending request’s `trip` ref.
  final String? tripId;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;

  /// From `GET` trip `passengerLiveLocation` when passenger shares GPS.
  final double? passengerLiveLatitude;
  final double? passengerLiveLongitude;

  /// Server trip status string (e.g. `driver_en_route`).
  final String? tripStatus;

  RideRequest copyWith({
    String? passengerName,
    double? passengerRating,
    int? passengerTrips,
    String? pickupAddress,
    String? dropoffAddress,
    int? estimatedFare,
    int? timeRemainingSeconds,
    String? apiRequestId,
    String? tripId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    double? passengerLiveLatitude,
    double? passengerLiveLongitude,
    String? tripStatus,
  }) {
    return RideRequest(
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      passengerTrips: passengerTrips ?? this.passengerTrips,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      apiRequestId: apiRequestId ?? this.apiRequestId,
      tripId: tripId ?? this.tripId,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      passengerLiveLatitude:
          passengerLiveLatitude ?? this.passengerLiveLatitude,
      passengerLiveLongitude:
          passengerLiveLongitude ?? this.passengerLiveLongitude,
      tripStatus: tripStatus ?? this.tripStatus,
    );
  }
}
