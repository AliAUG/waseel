import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/location_data.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/screens/location_search_screen.dart';
import 'package:waseel/features/passenger/screens/searching_for_driver_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({
    super.key,
    /// Matches previous `SELECT RIDE` entry points (e.g. legacy home).
    this.rideBookingFlow = false,
  });

  final bool rideBookingFlow;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  bool _confirmLoading = false;

  Map<String, dynamic> _locationPayload(LocationData d) => <String, dynamic>{
        'address': d.address,
        'latitude': d.lat,
        'longitude': d.lng,
      };

  String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }

  Future<void> _confirmRide(
    BuildContext context,
    RideProvider rideProvider,
  ) async {
    if (_confirmLoading) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null ||
        token.isEmpty ||
        token == 'local-session') {
      if (!context.mounted) return;
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.tripRequiresEmailLogin)),
      );
      return;
    }

    final pickup = rideProvider.pickupLocation ?? LocationData.tripoli;
    final destination = rideProvider.destination ?? LocationData.halba;
    final selected = rideProvider.selectedRideType;
    if (selected == null) {
      if (!context.mounted) return;
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.pleaseSelectRideType)),
      );
      return;
    }

    setState(() => _confirmLoading = true);
    final api = TripApiService();
    try {
      var rideTypeId = selected.backendId;
      if (rideTypeId == null || rideTypeId.isEmpty) {
        final types = await api.getRideTypes();
        for (final t in types) {
          if (t.category == selected.category) {
            rideTypeId = t.backendId;
            break;
          }
        }
      }
      if (rideTypeId == null || rideTypeId.isEmpty) {
        if (!context.mounted) return;
        final flow = PassengerFlowStrings(
          context.read<SettingsProvider>().language,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(flow.rideTypeServerConfigError)),
        );
        return;
      }

      final meters = Geolocator.distanceBetween(
        pickup.lat,
        pickup.lng,
        destination.lat,
        destination.lng,
      );
      final distanceKm = meters / 1000.0;
      final timeMinutes = (distanceKm * 2).round().clamp(1, 180);

      final resp = await api.createTrip(
        token: token,
        pickupLocation: _locationPayload(pickup),
        dropoffLocation: _locationPayload(destination),
        rideTypeId: rideTypeId,
        distanceKm: distanceKm,
        timeMinutes: timeMinutes,
      );

      final data = resp['data'];
      String? tripId;
      if (data is Map<String, dynamic>) {
        tripId = _parseMongoId(data['_id']);
      }
      rideProvider.setActiveTripId(tripId);

      if (!context.mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const SearchingForDriverScreen(),
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _confirmLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rideProvider = context.read<RideProvider>();
      if (rideProvider.selectedRideType == null &&
          rideProvider.homeRideTypes.isNotEmpty) {
        rideProvider.setSelectedRideType(rideProvider.homeRideTypes.first);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        _applyDefaultLocations();
        return;
      }
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _applyDefaultLocations();
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final rideProvider = context.read<RideProvider>();
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      if (rideProvider.pickupLocation == null) {
        rideProvider.setPickupLocation(LocationData(
          lat: position.latitude,
          lng: position.longitude,
          address: flow.currentLocationLebanon,
        ));
      }
      if (rideProvider.destination == null) {
        rideProvider.setDestination(LocationData.halba);
      }
    } catch (_) {
      _applyDefaultLocations();
    }
  }

  void _applyDefaultLocations() {
    if (!mounted) return;
    final rideProvider = context.read<RideProvider>();
    if (rideProvider.pickupLocation == null) {
      rideProvider.setPickupLocation(LocationData.tripoli);
    }
    if (rideProvider.destination == null) {
      rideProvider.setDestination(LocationData.halba);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        final pickup = rideProvider.pickupLocation ?? LocationData.tripoli;
        final destination = rideProvider.destination ?? LocationData.halba;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: Colors.grey.shade800,
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              widget.rideBookingFlow
                  ? flow.selectRideBookingAppBar
                  : flow.selectLocationAppBar,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 11,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2697E8),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset(
                      'assets/images/select_location_figma.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFE3E3E3),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LocationRouteCard(
                          pickupLabel: flow.pickupFieldLabel,
                          pickupValue: pickup.address,
                          destinationLabel: flow.destinationFieldLabel,
                          destinationValue: destination.address,
                          onPickupTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchPickupTitle,
                                  currentValue: pickup.address,
                                  showUseCurrentLocation: true,
                                  onLocationSelected:
                                      rideProvider.setPickupLocation,
                                ),
                              ),
                            );
                          },
                          onDestinationTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchDestinationTitle,
                                  currentValue: destination.address,
                                  onLocationSelected:
                                      rideProvider.setDestination,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          flow.chooseRide,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            rideProvider.selectedRideType == null
                                ? flow.pleaseSelectRideType
                                : (flow.isArabic
                                      ? rideProvider.selectedRideType!.arabicLabel
                                      : rideProvider.selectedRideType!.label),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmLoading
                                ? null
                                : () => _confirmRide(context, rideProvider),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _confirmLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(flow.confirmRide),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _LocationRouteCard extends StatelessWidget {
  const _LocationRouteCard({
    required this.pickupLabel,
    required this.pickupValue,
    required this.destinationLabel,
    required this.destinationValue,
    required this.onPickupTap,
    required this.onDestinationTap,
  });

  final String pickupLabel;
  final String pickupValue;
  final String destinationLabel;
  final String destinationValue;
  final VoidCallback onPickupTap;
  final VoidCallback onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 38,
                  color: Colors.grey.shade300,
                ),
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _RouteLocationField(
                  label: pickupLabel,
                  value: pickupValue,
                  onTap: onPickupTap,
                ),
                const SizedBox(height: 10),
                _RouteLocationField(
                  label: destinationLabel,
                  value: destinationValue,
                  onTap: onDestinationTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLocationField extends StatelessWidget {
  const _RouteLocationField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
