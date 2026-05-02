import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/location_data.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/location_search_screen.dart';
import 'package:waseel/features/passenger/screens/searching_for_driver_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({
    super.key,
    this.rideBookingFlow = false,
  });

  final bool rideBookingFlow;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  bool _confirmLoading = false;

  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _pointManager;

  Uint8List? _pickupMarkerBytes;
  Uint8List? _destinationMarkerBytes;

  bool _assigningPickup = false;
  bool _assigningDestination = true;

  @override
  void initState() {
    super.initState();
    _createMarkerIcons();
    _getCurrentLocation();
  }

  Future<void> _createMarkerIcons() async {
    _pickupMarkerBytes = await _buildMaterialMarkerIcon(
      icon: Icons.my_location,
      color: AppTheme.primaryTeal,
    );

    _destinationMarkerBytes = await _buildMaterialMarkerIcon(
      icon: Icons.location_on,
      color: Colors.red,
    );
  }

  Future<Uint8List> _buildMaterialMarkerIcon({
    required IconData icon,
    required Color color,
  }) async {
    const double size = 120;
    const double iconSize = 54;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final center = Offset(size / 2, size / 2.35);

    canvas.drawCircle(center.translate(0, 5), 38, shadowPaint);
    canvas.drawCircle(center, 38, paint);

    final pinPath = Path()
      ..moveTo(size / 2 - 18, size / 2 + 22)
      ..quadraticBezierTo(size / 2, size - 8, size / 2 + 18, size / 2 + 22)
      ..close();

    canvas.drawPath(pinPath.shift(const Offset(0, 5)), shadowPaint);
    canvas.drawPath(pinPath, paint);

    canvas.drawCircle(center, 27, Paint()..color = Colors.white);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return bytes!.buffer.asUint8List();
  }

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

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointManager = await mapboxMap.annotations.createPointAnnotationManager();

    if (_pickupMarkerBytes == null || _destinationMarkerBytes == null) {
      await _createMarkerIcons();
    }

    final rideProvider = context.read<RideProvider>();

    await _refreshMapMarkers(
      rideProvider.pickupLocation,
      rideProvider.destination,
      animate: false,
    );
  }

  Future<void> _handleMapTap(
    mapbox.MapContentGestureContext tapContext,
  ) async {
    final coordinates = tapContext.point.coordinates;

    final lng = coordinates.lng.toDouble();
    final lat = coordinates.lat.toDouble();

    final rideProvider = context.read<RideProvider>();

    final selectedLocation = LocationData(
      lat: lat,
      lng: lng,
      address: _assigningPickup
          ? 'Pickup selected on map'
          : 'Destination selected on map',
    );

    if (_assigningPickup) {
      rideProvider.setPickupLocation(selectedLocation);
    } else {
      rideProvider.setDestination(selectedLocation);
    }

    await _refreshMapMarkers(
      rideProvider.pickupLocation,
      rideProvider.destination,
    );
  }

  Future<void> _refreshMapMarkers(
    LocationData? pickup,
    LocationData? destination, {
    bool animate = true,
  }) async {
    final manager = _pointManager;
    if (manager == null) return;

    await manager.deleteAll();

    if (pickup != null && _pickupMarkerBytes != null) {
      await manager.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(pickup.lng, pickup.lat),
          ),
          image: _pickupMarkerBytes!,
          iconSize: 1.15,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'Pickup',
          textOffset: [0, 1.4],
          textSize: 14,
          textColor: AppTheme.primaryTeal.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    if (destination != null && _destinationMarkerBytes != null) {
      await manager.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(destination.lng, destination.lat),
          ),
          image: _destinationMarkerBytes!,
          iconSize: 1.15,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'Destination',
          textOffset: [0, 1.4],
          textSize: 14,
          textColor: Colors.red.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    final center = destination ?? pickup;
    if (center == null) return;

    final camera = mapbox.CameraOptions(
      center: mapbox.Point(
        coordinates: mapbox.Position(center.lng, center.lat),
      ),
      zoom: 14,
    );

    if (animate) {
      await _mapboxMap?.flyTo(
        camera,
        mapbox.MapAnimationOptions(duration: 700),
      );
    } else {
      await _mapboxMap?.setCamera(camera);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return;
      }

      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) return;

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final rideProvider = context.read<RideProvider>();
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );

      if (rideProvider.pickupLocation == null) {
        final currentLocation = LocationData(
          lat: position.latitude,
          lng: position.longitude,
          address: flow.currentLocationLebanon,
        );

        rideProvider.setPickupLocation(currentLocation);

        await _refreshMapMarkers(
          rideProvider.pickupLocation,
          rideProvider.destination,
        );
      }
    } catch (_) {}
  }

  Future<void> _confirmRide(
    BuildContext context,
    RideProvider rideProvider,
  ) async {
    if (_confirmLoading) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;

    final flow = PassengerFlowStrings(
      context.read<SettingsProvider>().language,
    );

    if (token == null || token.isEmpty || token == 'local-session') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.tripRequiresEmailLogin)),
      );
      return;
    }

    final pickup = rideProvider.pickupLocation;
    final destination = rideProvider.destination;
    final selected = rideProvider.selectedRideType;

    if (pickup == null || destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pickup and destination locations.'),
        ),
      );
      return;
    }

    if (selected == null) {
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
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(
      context.watch<SettingsProvider>().language,
    );

    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        final pickup = rideProvider.pickupLocation;
        final destination = rideProvider.destination;
        final mapCenter = destination ?? pickup;

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
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      mapbox.MapWidget(
                        onMapCreated: _onMapCreated,
                        onTapListener: _handleMapTap,
                        cameraOptions: mapbox.CameraOptions(
                          center: mapbox.Point(
                            coordinates: mapbox.Position(
                              mapCenter?.lng ?? 35.5018,
                              mapCenter?.lat ?? 33.8938,
                            ),
                          ),
                          zoom: mapCenter == null ? 8 : 12,
                        ),
                        styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: _MapInfoCard(
                          pickup: pickup,
                          destination: destination,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _MapAssignToggle(
                          assigningPickup: _assigningPickup,
                          assigningDestination: _assigningDestination,
                          onPickupTap: () {
                            setState(() {
                              _assigningPickup = true;
                              _assigningDestination = false;
                            });
                          },
                          onDestinationTap: () {
                            setState(() {
                              _assigningPickup = false;
                              _assigningDestination = true;
                            });
                          },
                        ),
                      ),
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
                          value: pickup?.address ?? 'Search pickup location',
                          placeholder: pickup == null,
                          onTap: () {
                            setState(() {
                              _assigningPickup = true;
                              _assigningDestination = false;
                            });

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchPickupTitle,
                                  currentValue: pickup?.address ?? '',
                                  showUseCurrentLocation: true,
                                  onLocationSelected: (loc) async {
                                    rideProvider.setPickupLocation(loc);

                                    await _refreshMapMarkers(
                                      rideProvider.pickupLocation,
                                      rideProvider.destination,
                                    );
                                  },
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
                          value: destination?.address ??
                              'Search destination location',
                          placeholder: destination == null,
                          onTap: () {
                            setState(() {
                              _assigningPickup = false;
                              _assigningDestination = true;
                            });

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationSearchScreen(
                                  title: flow.locationSearchDestinationTitle,
                                  currentValue: destination?.address ?? '',
                                  onLocationSelected: (loc) async {
                                    rideProvider.setDestination(loc);

                                    await _refreshMapMarkers(
                                      rideProvider.pickupLocation,
                                      rideProvider.destination,
                                    );
                                  },
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
                        if (rideProvider.homeRideTypes.isEmpty)
                          Text(
                            flow.noRideTypesLoaded,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: rideProvider.homeRideTypes.map((type) {
                              final selected =
                                  rideProvider.selectedRideType?.category ==
                                      type.category;

                              return _RideChoiceChip(
                                label: flow.isArabic
                                    ? type.arabicLabel
                                    : type.label,
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

class _MapAssignToggle extends StatelessWidget {
  const _MapAssignToggle({
    required this.assigningPickup,
    required this.assigningDestination,
    required this.onPickupTap,
    required this.onDestinationTap,
  });

  final bool assigningPickup;
  final bool assigningDestination;
  final VoidCallback onPickupTap;
  final VoidCallback onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _AssignButton(
                label: 'Set pickup',
                selected: assigningPickup,
                color: AppTheme.primaryTeal,
                onTap: onPickupTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AssignButton(
                label: 'Set destination',
                selected: assigningDestination,
                color: Colors.red,
                onTap: onDestinationTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignButton extends StatelessWidget {
  const _AssignButton({
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
      color: selected ? color.withValues(alpha: 0.14) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? color : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapInfoCard extends StatelessWidget {
  const _MapInfoCard({
    required this.pickup,
    required this.destination,
  });

  final LocationData? pickup;
  final LocationData? destination;

  @override
  Widget build(BuildContext context) {
    final pickupText = pickup?.address ?? 'Select pickup';
    final destinationText = destination?.address ?? 'Select destination';

    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.my_location, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$pickupText → $destinationText',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
            color:
                selected ? color.withValues(alpha: 0.16) : Colors.grey.shade100,
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
              color: selected ? color : Colors.grey.shade700,
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
    this.placeholder = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool placeholder;

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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          placeholder ? FontWeight.w400 : FontWeight.w500,
                      color: placeholder
                          ? Colors.grey.shade500
                          : Colors.grey.shade900,
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
