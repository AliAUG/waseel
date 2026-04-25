import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/models/ride_request.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_complete_trip_screen.dart';
import 'package:waseel/features/driver/strings/driver_ui_strings.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class DriverStartTripScreen extends StatefulWidget {
  const DriverStartTripScreen({super.key, required this.ride});

  final RideRequest ride;

  @override
  State<DriverStartTripScreen> createState() => _DriverStartTripScreenState();
}

class _DriverStartTripScreenState extends State<DriverStartTripScreen> {
  late RideRequest _ride;

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTripDetails());
  }

  Future<void> _loadTripDetails() async {
    final auth = context.read<AuthProvider>();
    final merged = await context.read<DriverProvider>().mergeRideWithServerTrip(
          _ride,
          auth.token,
        );
    if (!mounted) return;
    setState(() => _ride = merged);
  }

  @override
  Widget build(BuildContext context) {
    final ride = _ride;
    final d = DriverUiStrings(context.watch<SettingsProvider>().language);
    final flow =
        PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          flow.tripTitleStart,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation, color: AppTheme.primaryTeal),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 48, color: AppTheme.primaryTeal),
                    const SizedBox(width: 24),
                    Icon(Icons.place, size: 56, color: Colors.red.shade400),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _RideDetailsCard(
              d: d,
              status: d.statusArrivedAtPickup,
              subtext: d.subtextWaiting,
              ride: ride,
              pickupLabel: d.pickupLocationLabel,
              dropoffLabel: d.dropoffLocationLabel,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final token = context.read<AuthProvider>().token;
                    final ok = await context.read<DriverProvider>().updateTripStatus(
                          token,
                          ride.tripId,
                          'en_route',
                        );
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(d.tripStatusFailed)),
                      );
                      return;
                    }
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DriverCompleteTripScreen(ride: _ride),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(d.startTrip),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RideDetailsCard extends StatelessWidget {
  const _RideDetailsCard({
    required this.d,
    required this.status,
    required this.subtext,
    required this.ride,
    required this.pickupLabel,
    required this.dropoffLabel,
    required this.child,
  });

  final DriverUiStrings d;
  final String status;
  final String subtext;
  final RideRequest ride;
  final String pickupLabel;
  final String dropoffLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  d.fareLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  formatLebanesePounds(ride.estimatedFare),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PassengerRow(ride: ride, d: d),
            const SizedBox(height: 20),
            _LocationRow(icon: Icons.place, color: Colors.green, label: pickupLabel, address: ride.pickupAddress),
            const SizedBox(height: 12),
            _LocationRow(icon: Icons.place, color: Colors.red, label: dropoffLabel, address: ride.dropoffAddress),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  const _PassengerRow({required this.ride, required this.d});

  final RideRequest ride;
  final DriverUiStrings d;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.person, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.passengerName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    d.passengerRatingLine(ride.passengerRating),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: AppTheme.primaryTeal),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline,
              color: AppTheme.primaryTeal),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
