import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/mixins/passenger_trip_poll_mixin.dart';
import 'package:waseel/features/passenger/models/driver_info.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/rating_screen.dart';
import 'package:waseel/features/passenger/screens/start_trip_screen.dart';
import 'package:waseel/features/passenger/screens/complete_trip_screen.dart';
import 'package:waseel/features/shared/widgets/live_trip_map.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class DriverInfoScreen extends StatefulWidget {
  const DriverInfoScreen({
    super.key,
    this.driverInfo,
  });

  final DriverInfo? driverInfo;

  @override
  State<DriverInfoScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<DriverInfoScreen>
    with PassengerTripPollMixin {
  late DriverInfo _driverInfo;
  bool _navigated = false;
  int? _etaMinutes;

  @override
  void initState() {
    super.initState();
    _driverInfo = widget.driverInfo ?? DriverInfo.placeholder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final ride = context.read<RideProvider>();
      final tripId = ride.activeTripId;
      final token = auth.token;
      if (tripId == null ||
          tripId.isEmpty ||
          token == null ||
          token.isEmpty ||
          token == 'local-session') {
        return;
      }
      startTripPoll(() => _pollTrip(token, tripId));
    });
  }

  Future<void> _pollTrip(String token, String tripId) async {
    if (!mounted || _navigated) return;
    final flow = PassengerFlowStrings(context.read<SettingsProvider>().language);
    final api = TripApiService();
    final d = await api.getTripDetails(token, tripId);
    if (!mounted || _navigated) return;
    if (d == null) return;

    if (d.status == 'cancelled') {
      _navigated = true;
      stopTripPoll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.tripCancelledDuringSearch)),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    final info = DriverInfo.fromTripHistory(d);
    final eta = d.estimatedArrivalMinutes;
    setState(() {
      _driverInfo = info;
      _etaMinutes = eta;
    });
    final ride = context.read<RideProvider>();
    if (d.driverLatitude != null && d.driverLongitude != null) {
      ride.updateDriverPosition(
        d.driverLatitude!,
        d.driverLongitude!,
        info.location,
      );
    }

    final s = d.status;
    if (s == null) return;

    if (s == 'driver_arrived') {
      _navigated = true;
      stopTripPoll();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StartTripScreen(driverInfo: info),
        ),
      );
      return;
    }
    if (s == 'en_route') {
      _navigated = true;
      stopTripPoll();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CompleteTripScreen(driverInfo: info),
        ),
      );
      return;
    }
    if (s == 'completed') {
      _navigated = true;
      stopTripPoll();
      if (!mounted) return;
      final tid = context.read<RideProvider>().activeTripId;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => RatingScreen(
            driverName: info.name,
            tripId: tid,
          ),
        ),
        (route) => route.isFirst,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    final eta = _etaMinutes != null ? flow.minAwayLabel(_etaMinutes!) : null;
    final ride = context.watch<RideProvider>();
    final pickup = ride.pickupLocation;
    final fallbackDriver = pickup == null
        ? null
        : LatLng(pickup.lat + 0.0032, pickup.lng + 0.0032);
    final driverPoint = (ride.driverLat != null && ride.driverLng != null)
        ? LatLng(ride.driverLat!, ride.driverLng!)
        : fallbackDriver;
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
        centerTitle: true,
        title: Text(
          flow.driverInfoAppBar,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: pickup == null || driverPoint == null
                ? _MapPlaceholder(status: flow.driverOnTheWay, eta: eta)
                : Stack(
                    children: [
                      LiveTripMap(
                        primaryPoint: driverPoint,
                        secondaryPoint: LatLng(pickup.lat, pickup.lng),
                        primaryLabel: 'Driver',
                        secondaryLabel: 'Passenger',
                        destinationPoint: ride.destination == null
                            ? null
                            : LatLng(ride.destination!.lat, ride.destination!.lng),
                      ),
                      _MapStatusOverlay(status: flow.driverOnTheWay, eta: eta),
                    ],
                  ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DriverCard(driverInfo: _driverInfo),
                  const SizedBox(height: 24),
                  _ActionButtons(flow: flow),
                  const SizedBox(height: 20),
                  _EmergencyButton(flow: flow),
                  const SizedBox(height: 32),
                  if (kDebugMode)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  StartTripScreen(driverInfo: _driverInfo),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: Text(flow.simulateDriverArrived),
                      ),
                    ),
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
  const _MapPlaceholder({
    required this.status,
    this.eta,
  });

  final String status;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(20),
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
          Positioned(
            bottom: 12,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                if (eta != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    eta!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapStatusOverlay extends StatelessWidget {
  const _MapStatusOverlay({
    required this.status,
    this.eta,
  });

  final String status;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          if (eta != null) ...[
            const SizedBox(height: 8),
            Text(
              eta!,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driverInfo});

  final DriverInfo driverInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              '👤',
              style: TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverInfo.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      driverInfo.rating.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  driverInfo.vehicle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  driverInfo.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.flow});

  final PassengerFlowStrings flow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(icon: Icons.phone, label: flow.callDriver),
        _ActionButton(icon: Icons.chat_bubble_outline, label: flow.chatDriver),
        _ActionButton(icon: Icons.share, label: flow.shareTrip),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.flow});

  final PassengerFlowStrings flow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Emergency action
        },
        icon: Icon(Icons.shield_outlined, color: Colors.red.shade700, size: 22),
        label: Text(
          flow.emergency,
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }
}
