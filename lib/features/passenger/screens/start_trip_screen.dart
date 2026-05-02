import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/mixins/passenger_trip_poll_mixin.dart';
import 'package:waseel/features/passenger/models/driver_info.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/complete_trip_screen.dart';
import 'package:waseel/features/passenger/screens/rating_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({
    super.key,
    this.driverInfo,
  });

  final DriverInfo? driverInfo;

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen>
    with PassengerTripPollMixin {
  late DriverInfo _driverInfo;
  bool _navigated = false;

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
    setState(() => _driverInfo = info);

    final s = d.status;
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
          flow.tripTitleStart,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ),
      body: Column(
        children: [
          _MapPlaceholder(status: flow.mapStatusDriverArrived),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DriverCard(driverInfo: _driverInfo),
                  const SizedBox(height: 24),
                  _ActionButtons(),
                  const SizedBox(height: 20),
                  _EmergencyButton(),
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
  const _MapPlaceholder({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚗', style: TextStyle(fontSize: 48)),
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
            child: Row(
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
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
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
            child: const Text('👤', style: TextStyle(fontSize: 32)),
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
  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
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
  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
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
