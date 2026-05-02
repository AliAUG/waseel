import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/location_data.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/saved_places_provider.dart';
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
        currency: 'USD',
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
      final token = context.read<AuthProvider>().token;
      context.read<SavedPlacesProvider>().refresh(token: token);
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: Color(0xFFE3E3E3)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LocationField(
                          icon: Icons.place,
                          iconColor: AppTheme.primaryTeal,
                          label: flow.pickupFieldLabel,
                          value: pickup.address,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchPickupTitle,
                                  currentValue: pickup.address,
                                  showUseCurrentLocation: true,
                                  onLocationSelected: rideProvider.setPickupLocation,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _LocationField(
                          icon: Icons.place,
                          iconColor: Colors.red,
                          label: flow.destinationFieldLabel,
                          value: destination.address,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchDestinationTitle,
                                  currentValue: destination.address,
                                  onLocationSelected: rideProvider.setDestination,
                                ),
                              ),
                            );
                          },
                        ),
                        Consumer<SavedPlacesProvider>(
                          builder: (context, saved, _) {
                            if (saved.places.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flow.selectLocationSavedPlaces,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    flow.selectLocationSavedPlacesHint,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: saved.places.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, i) {
                                        final p = saved.places[i];
                                        return ActionChip(
                                          label: Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.grey.shade100,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          onPressed: () {
                                            rideProvider.setDestination(
                                              p.toLocationData(),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: rideProvider.homeRideTypes.map((type) {
                            final selected =
                                rideProvider.selectedRideType?.category ==
                                    type.category;
                            return _RideChoiceChip(
                              label: flow.isArabic ? type.arabicLabel : type.label,
                              selected: selected,
                              color: type.color,
                              onTap: () {
                                rideProvider.setSelectedRideType(type);
                              },
                            );
                          }).toList(),
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

class _RideChoiceChip extends StatelessWidget {
  const _RideChoiceChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.16) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
