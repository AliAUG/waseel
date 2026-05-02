import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:waseel/core/theme.dart';

/// Whether route emphasis is toward pickup or dropoff.
enum DriverTripNavPhase {
  headingToPickup,
  headingToDropoff,
}

/// Mapbox map for driver active trips: driver, passenger live (or pickup), optional dropoff, route segments.
class DriverTripMapbox extends StatefulWidget {
  const DriverTripMapbox({
    super.key,
    this.driverLatitude,
    this.driverLongitude,
    this.passengerLiveLatitude,
    this.passengerLiveLongitude,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.passengerUsesLiveLocation = false,
    this.phase = DriverTripNavPhase.headingToPickup,
    this.secondaryPinLabel = 'Passenger',
  });

  final double? driverLatitude;
  final double? driverLongitude;
  final double? passengerLiveLatitude;
  final double? passengerLiveLongitude;
  final double pickupLatitude;
  final double pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;

  /// When true, secondary pin uses live passenger coords (fallback: pickup).
  final bool passengerUsesLiveLocation;

  /// [headingToDropoff] draws driver → dropoff; pickup stays as reference.
  final DriverTripNavPhase phase;

  /// Label on the pickup / passenger meeting pin.
  final String secondaryPinLabel;

  @override
  State<DriverTripMapbox> createState() => _DriverTripMapboxState();
}

class _DriverTripMapboxState extends State<DriverTripMapbox> {
  mapbox.MapboxMap? _map;
  mapbox.PointAnnotationManager? _points;
  mapbox.PolylineAnnotationManager? _lines;

  Uint8List? _driverIcon;
  Uint8List? _passengerIcon;
  Uint8List? _dropoffIcon;

  @override
  void initState() {
    super.initState();
    _ensureIcons();
  }

  @override
  void didUpdateWidget(covariant DriverTripMapbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLatitude != widget.driverLatitude ||
        oldWidget.driverLongitude != widget.driverLongitude ||
        oldWidget.passengerLiveLatitude != widget.passengerLiveLatitude ||
        oldWidget.passengerLiveLongitude != widget.passengerLiveLongitude ||
        oldWidget.pickupLatitude != widget.pickupLatitude ||
        oldWidget.pickupLongitude != widget.pickupLongitude ||
        oldWidget.dropoffLatitude != widget.dropoffLatitude ||
        oldWidget.dropoffLongitude != widget.dropoffLongitude ||
        oldWidget.passengerUsesLiveLocation != widget.passengerUsesLiveLocation ||
        oldWidget.phase != widget.phase ||
        oldWidget.secondaryPinLabel != widget.secondaryPinLabel) {
      _syncAnnotations();
    }
  }

  Future<void> _ensureIcons() async {
    _driverIcon ??= await _buildMarkerIcon(
      icon: Icons.navigation,
      color: Colors.blue.shade700,
    );
    _passengerIcon ??= await _buildMarkerIcon(
      icon: Icons.person_pin_circle,
      color: AppTheme.primaryTeal,
    );
    _dropoffIcon ??= await _buildMarkerIcon(
      icon: Icons.flag,
      color: Colors.red.shade700,
    );
    if (mounted) await _syncAnnotations();
  }

  Future<Uint8List> _buildMarkerIcon({
    required IconData icon,
    required Color color,
  }) async {
    const double size = 96;
    const double iconSize = 44;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final center = Offset(size / 2, size / 2.35);

    canvas.drawCircle(center.translate(0, 4), 30, shadowPaint);
    canvas.drawCircle(center, 30, paint);
    canvas.drawCircle(center, 20, Paint()..color = Colors.white);

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
    )..layout();

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

  Future<void> _onMapCreated(mapbox.MapboxMap controller) async {
    _map = controller;
    _points = await controller.annotations.createPointAnnotationManager();
    _lines = await controller.annotations.createPolylineAnnotationManager();
    await _ensureIcons();
    await _fitCamera();
  }

  double get _passengerLat => widget.passengerUsesLiveLocation &&
          widget.passengerLiveLatitude != null &&
          widget.passengerLiveLongitude != null
      ? widget.passengerLiveLatitude!
      : widget.pickupLatitude;

  double get _passengerLng => widget.passengerUsesLiveLocation &&
          widget.passengerLiveLatitude != null &&
          widget.passengerLiveLongitude != null
      ? widget.passengerLiveLongitude!
      : widget.pickupLongitude;

  Future<void> _syncAnnotations() async {
    final points = _points;
    final lines = _lines;
    if (points == null || lines == null) return;
    if (_driverIcon == null ||
        _passengerIcon == null ||
        _dropoffIcon == null) {
      return;
    }

    await points.deleteAll();
    await lines.deleteAll();

    final dLat = widget.driverLatitude;
    final dLng = widget.driverLongitude;
    if (dLat != null && dLng != null) {
      await points.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(dLng, dLat),
          ),
          image: _driverIcon!,
          iconSize: 1.0,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'You',
          textOffset: [0, 1.2],
          textSize: 12,
          textColor: Colors.blue.shade900.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    await points.create(
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(_passengerLng, _passengerLat),
        ),
        image: _passengerIcon!,
        iconSize: 1.0,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        textField: widget.secondaryPinLabel,
        textOffset: [0, 1.2],
        textSize: 12,
        textColor: AppTheme.primaryTeal.value,
        textHaloColor: Colors.white.value,
        textHaloWidth: 2,
      ),
    );

    final drop = widget.dropoffLatitude != null && widget.dropoffLongitude != null
        ? (widget.dropoffLatitude!, widget.dropoffLongitude!)
        : null;

    if (drop != null) {
      await points.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(drop.$2, drop.$1),
          ),
          image: _dropoffIcon!,
          iconSize: 1.0,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'Dropoff',
          textOffset: [0, 1.2],
          textSize: 12,
          textColor: Colors.red.shade900.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    if (widget.phase == DriverTripNavPhase.headingToPickup) {
      if (dLat != null && dLng != null) {
        await lines.create(
          mapbox.PolylineAnnotationOptions(
            geometry: mapbox.LineString.fromPoints(
              points: [
                mapbox.Point(coordinates: mapbox.Position(dLng, dLat)),
                mapbox.Point(
                  coordinates: mapbox.Position(_passengerLng, _passengerLat),
                ),
              ],
            ),
            lineColor: Colors.blue.value,
            lineWidth: 4,
          ),
        );
      }

      if (drop != null) {
        await lines.create(
          mapbox.PolylineAnnotationOptions(
            geometry: mapbox.LineString.fromPoints(
              points: [
                mapbox.Point(
                  coordinates: mapbox.Position(_passengerLng, _passengerLat),
                ),
                mapbox.Point(
                  coordinates: mapbox.Position(drop.$2, drop.$1),
                ),
              ],
            ),
            lineColor: Colors.green.value,
            lineWidth: 4,
          ),
        );
      }
    } else if (drop != null && dLat != null && dLng != null) {
      await lines.create(
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString.fromPoints(
            points: [
              mapbox.Point(coordinates: mapbox.Position(dLng, dLat)),
              mapbox.Point(
                coordinates: mapbox.Position(drop.$2, drop.$1),
              ),
            ],
          ),
          lineColor: Colors.green.value,
          lineWidth: 5,
        ),
      );
    }

    await _fitCamera();
  }

  Future<void> _fitCamera() async {
    final map = _map;
    if (map == null) return;

    final coords = <mapbox.Position>[
      mapbox.Position(_passengerLng, _passengerLat),
    ];
    final dLat = widget.driverLatitude;
    final dLng = widget.driverLongitude;
    if (dLat != null && dLng != null) {
      coords.add(mapbox.Position(dLng, dLat));
    }
    if (widget.dropoffLatitude != null && widget.dropoffLongitude != null) {
      coords.add(
        mapbox.Position(widget.dropoffLongitude!, widget.dropoffLatitude!),
      );
    }

    if (coords.isEmpty) return;

    var minLng = coords.first.lng.toDouble();
    var maxLng = minLng;
    var minLat = coords.first.lat.toDouble();
    var maxLat = minLat;
    for (final c in coords) {
      final lng = c.lng.toDouble();
      final lat = c.lat.toDouble();
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
    }

    final centerLng = (minLng + maxLng) / 2;
    final centerLat = (minLat + maxLat) / 2;
    final span = (maxLng - minLng).abs() + (maxLat - minLat).abs();
    var zoom = 13.5;
    if (span > 0.15) zoom = 11;
    if (span > 0.35) zoom = 10;
    if (span < 0.02) zoom = 14.5;

    await map.easeTo(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(centerLng, centerLat),
        ),
        zoom: zoom,
      ),
      mapbox.MapAnimationOptions(duration: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dLat = widget.driverLatitude;
    final dLng = widget.driverLongitude;
    final centerLng = dLng ?? _passengerLng;
    final centerLat = dLat ?? _passengerLat;

    return mapbox.MapWidget(
      onMapCreated: _onMapCreated,
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(centerLng, centerLat),
        ),
        zoom: 13,
      ),
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
    );
  }
}
