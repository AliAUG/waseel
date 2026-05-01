import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/driver_info.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/driver_info_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class SearchingForDriverScreen extends StatefulWidget {
  const SearchingForDriverScreen({super.key});

  @override
  State<SearchingForDriverScreen> createState() =>
      _SearchingForDriverScreenState();
}

class _SearchingForDriverScreenState extends State<SearchingForDriverScreen> {
  Timer? _timer;
  bool _stopped = false;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPolling());
  }

  void _stop() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pollOnce() async {
    if (!mounted || _stopped || _inFlight) return;
    _inFlight = true;
    try {
      final ride = context.read<RideProvider>();
      final auth = context.read<AuthProvider>();
      final flow =
          PassengerFlowStrings(context.read<SettingsProvider>().language);
      final tripId = ride.activeTripId;
      final token = auth.token;

      if (tripId == null ||
          tripId.isEmpty ||
          token == null ||
          token.isEmpty ||
          token == 'local-session') {
        _stop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tripId == null || tripId.isEmpty
                    ? flow.tripMissingIdError
                    : flow.tripRequiresEmailLogin,
              ),
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      final api = TripApiService();
      final details = await api.getTripDetails(token, tripId);
      if (!mounted || _stopped) return;
      if (details == null) return;

      if (details.status == 'cancelled') {
        _stop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(flow.tripCancelledDuringSearch)),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      if (details.hasAssignedDriver) {
        _stop();
        final info = DriverInfo.fromTripHistory(details);
        final etaMin = details.estimatedArrivalMinutes;
        final eta = etaMin != null ? '$etaMin min away' : null;
        ride.assignDriver(info, eta: eta);
        if (!mounted) return;
        final nav = Navigator.of(context);
        nav.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => DriverInfoScreen(driverInfo: info),
          ),
          (route) => route.isFirst,
        );
      }
    } finally {
      _inFlight = false;
    }
  }

  void _startPolling() {
    final ride = context.read<RideProvider>();
    final auth = context.read<AuthProvider>();
    final flow =
        PassengerFlowStrings(context.read<SettingsProvider>().language);
    final tripId = ride.activeTripId;
    final token = auth.token;

    if (tripId == null || tripId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.tripMissingIdError)),
      );
      Navigator.of(context).pop();
      return;
    }
    if (token == null || token.isEmpty || token == 'local-session') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.tripRequiresEmailLogin)),
      );
      Navigator.of(context).pop();
      return;
    }

    _pollOnce();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow =
        PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.searchDriverAppBar,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const _MapPlaceholder(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        flow.findingDriver,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    flow.usuallyUnderMinute,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          const found = DriverInfo(
                            name: 'Ahmed Al-Mansoori',
                            rating: 4.9,
                            vehicle: 'Toyota Camry - White',
                            location: 'Lebanon - Tripoli',
                          );
                          _stop();
                          context.read<RideProvider>().assignDriver(
                                found,
                                eta: '3 min away',
                              );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => DriverInfoScreen(
                                driverInfo: found,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: Text(flow.simulateDriverFound),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🚗', style: TextStyle(fontSize: 48)),
                const SizedBox(width: 40),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
