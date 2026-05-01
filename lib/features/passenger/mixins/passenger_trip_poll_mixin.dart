import 'dart:async';

import 'package:flutter/material.dart';

/// Periodic async polling for passenger trip `GET /trips/:id/details`.
mixin PassengerTripPollMixin<T extends StatefulWidget> on State<T> {
  Timer? _tripPollTimer;
  bool _tripPollInFlight = false;

  void startTripPoll(Future<void> Function() onTick) {
    _tripPollTimer?.cancel();
    Future.microtask(() => _runOnce(onTick));
    _tripPollTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _runOnce(onTick));
  }

  Future<void> _runOnce(Future<void> Function() onTick) async {
    if (!mounted || _tripPollInFlight) return;
    _tripPollInFlight = true;
    try {
      await onTick();
    } finally {
      _tripPollInFlight = false;
    }
  }

  void stopTripPoll() {
    _tripPollTimer?.cancel();
    _tripPollTimer = null;
  }

  @override
  void dispose() {
    stopTripPoll();
    super.dispose();
  }
}
