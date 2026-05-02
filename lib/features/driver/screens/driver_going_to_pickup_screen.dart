import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/models/ride_request.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_start_trip_screen.dart';
import 'package:waseel/features/driver/services/driver_trip_live_session.dart';
import 'package:waseel/features/driver/strings/driver_ui_strings.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/shared/widgets/driver_trip_mapbox.dart';

class DriverGoingToPickupScreen extends StatefulWidget {
  const DriverGoingToPickupScreen({super.key, required this.ride});

  final RideRequest ride;

  @override
  State<DriverGoingToPickupScreen> createState() =>
      _DriverGoingToPickupScreenState();
}

class _DriverGoingToPickupScreenState extends State<DriverGoingToPickupScreen> {
  late RideRequest _ride;
  Position? _driverPosition;
  final _live = DriverTripLiveSession();

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _emitDriverEnRoute();
      await _loadTripDetails();
      _startLive();
    });
  }

  void _startLive() {
    final auth = context.read<AuthProvider>();
    final driver = context.read<DriverProvider>();
    _live.start(
      token: auth.token,
      driverProvider: driver,
      getRide: () => _ride,
      onTripMerged: (merged) {
        if (!mounted) return;
        setState(() => _ride = merged);
      },
      onDriverPosition: (pos) {
        if (!mounted) return;
        setState(() => _driverPosition = pos);
      },
    );
  }

  @override
  void dispose() {
    _live.stop();
    super.dispose();
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

  Future<void> _emitDriverEnRoute() async {
    final token = context.read<AuthProvider>().token;
    final ok = await context.read<DriverProvider>().updateTripStatus(
          token,
          widget.ride.tripId,
          'driver_en_route',
        );
    if (!mounted || ok) return;
    final d = DriverUiStrings(context.read<SettingsProvider>().language);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(d.tripStatusFailed)),
    );
  }

  Future<void> _openNavigationToPickup() async {
    final lat = _ride.pickupLatitude;
    final lng = _ride.pickupLongitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = _ride;
    final d = DriverUiStrings(context.watch<SettingsProvider>().language);
    final puLat = ride.pickupLatitude ?? 34.4367;
    final puLng = ride.pickupLongitude ?? 35.8497;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          d.goingToPickupAppBar,
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
            onPressed: _openNavigationToPickup,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: DriverTripMapbox(
              driverLatitude: _driverPosition?.latitude,
              driverLongitude: _driverPosition?.longitude,
              passengerLiveLatitude: ride.passengerLiveLatitude,
              passengerLiveLongitude: ride.passengerLiveLongitude,
              pickupLatitude: puLat,
              pickupLongitude: puLng,
              dropoffLatitude: ride.dropoffLatitude,
              dropoffLongitude: ride.dropoffLongitude,
              passengerUsesLiveLocation: ride.passengerLiveLatitude != null &&
                  ride.passengerLiveLongitude != null,
              phase: DriverTripNavPhase.headingToPickup,
            ),
          ),
          Expanded(
            flex: 3,
            child: _RideDetailsCard(
              d: d,
              status: ride.tripStatus ?? d.statusGoingToPickup,
              subtext: d.etaMinutes(5),
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
                          'driver_arrived',
                        );
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(d.tripStatusFailed)),
                      );
                      return;
                    }
                    _live.stop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DriverStartTripScreen(ride: _ride),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(d.arrivedAtPickup),
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
