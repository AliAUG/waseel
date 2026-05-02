import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:waseel/features/driver/data/driver_api_service.dart';
import 'package:waseel/features/driver/models/ride_request.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';

/// Polls trip + pushes driver GPS while a trip is active (REST sync; no WebSocket).
class DriverTripLiveSession {
  DriverTripLiveSession({DriverApiService? api})
      : _api = api ?? DriverApiService();

  final DriverApiService _api;

  StreamSubscription<Position>? _posSub;
  Timer? _pollTimer;
  Timer? _pushTimer;
  Position? _lastPosition;

  /// [getRide] must return the latest merged ride from the host widget state.
  void start({
    required String? token,
    required DriverProvider driverProvider,
    required RideRequest Function() getRide,
    required void Function(RideRequest merged) onTripMerged,
    required void Function(Position position) onDriverPosition,
  }) {
    stop();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final ride = getRide();
      final tid = ride.tripId;
      if (tid == null ||
          tid.isEmpty ||
          token == null ||
          token.isEmpty ||
          token == 'local-session') {
        return;
      }
      final merged =
          await driverProvider.mergeRideWithServerTrip(ride, token);
      onTripMerged(merged);
    });

    _pushTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      final pos = _lastPosition;
      final ride = getRide();
      final tid = ride.tripId;
      if (pos == null ||
          tid == null ||
          tid.isEmpty ||
          token == null ||
          token.isEmpty ||
          token == 'local-session') {
        return;
      }
      try {
        await _api.updateDriverLiveLocation(
          token: token,
          tripId: tid,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      } catch (_) {}
    });

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 12,
      ),
    ).listen((pos) {
      _lastPosition = pos;
      onDriverPosition(pos);
    });
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pushTimer?.cancel();
    _pushTimer = null;
    _posSub?.cancel();
    _posSub = null;
    _lastPosition = null;
  }
}
