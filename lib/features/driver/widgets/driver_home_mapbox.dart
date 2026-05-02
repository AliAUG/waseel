import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:waseel/features/driver/models/ride_request.dart';
import 'package:waseel/core/theme.dart';

/// Map strip on driver home: current GPS and optional incoming request pins.
class DriverHomeMapbox extends StatefulWidget {
  const DriverHomeMapbox({
    super.key,
    required this.driverLatitude,
    required this.driverLongitude,
    this.incomingRequest,
  });

  final double? driverLatitude;
  final double? driverLongitude;
  final RideRequest? incomingRequest;

  @override
  State<DriverHomeMapbox> createState() => _DriverHomeMapboxState();
}

class _DriverHomeMapboxState extends State<DriverHomeMapbox> {
  mapbox.MapboxMap? _map;
  mapbox.PointAnnotationManager? _points;

  Uint8List? _driverIcon;
  Uint8List? _pickupIcon;
  Uint8List? _dropIcon;

  @override
  void initState() {
    super.initState();
    _ensureIcons();
  }

  @override
  void didUpdateWidget(covariant DriverHomeMapbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLatitude != widget.driverLatitude ||
        oldWidget.driverLongitude != widget.driverLongitude ||
        oldWidget.incomingRequest?.apiRequestId !=
            widget.incomingRequest?.apiRequestId) {
      _syncAnnotations();
    }
  }

  Future<void> _ensureIcons() async {
    _driverIcon ??= await _icon(Icons.navigation, Colors.blue.shade700);
    _pickupIcon ??= await _icon(Icons.place, AppTheme.primaryTeal);
    _dropIcon ??= await _icon(Icons.flag, Colors.red.shade700);
    if (mounted) await _syncAnnotations();
  }

  Future<Uint8List> _icon(IconData icon, Color color) async {
    const size = 88.0;
    const iconSize = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final c = Offset(size / 2, size / 2);
    canvas.drawCircle(c, 28, Paint()..color = color);
    canvas.drawCircle(c, 18, Paint()..color = Colors.white);
    final tp = TextPainter(
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
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final b = await img.toByteData(format: ui.ImageByteFormat.png);
    return b!.buffer.asUint8List();
  }

  Future<void> _onMapCreated(mapbox.MapboxMap controller) async {
    _map = controller;
    _points = await controller.annotations.createPointAnnotationManager();
    await _ensureIcons();
  }

  Future<void> _syncAnnotations() async {
    final mgr = _points;
    if (mgr == null ||
        _driverIcon == null ||
        _pickupIcon == null ||
        _dropIcon == null) {
      return;
    }
    await mgr.deleteAll();

    final lat = widget.driverLatitude;
    final lng = widget.driverLongitude;
    final req = widget.incomingRequest;

    if (lat != null && lng != null) {
      await mgr.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
          image: _driverIcon!,
          iconSize: 0.95,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'You',
          textOffset: [0, 1.1],
          textSize: 11,
          textColor: Colors.blue.shade900.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    if (req != null &&
        req.pickupLatitude != null &&
        req.pickupLongitude != null) {
      await mgr.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              req.pickupLongitude!,
              req.pickupLatitude!,
            ),
          ),
          image: _pickupIcon!,
          iconSize: 0.95,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'Pickup',
          textOffset: [0, 1.1],
          textSize: 11,
          textColor: AppTheme.primaryTeal.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    if (req != null &&
        req.dropoffLatitude != null &&
        req.dropoffLongitude != null) {
      await mgr.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              req.dropoffLongitude!,
              req.dropoffLatitude!,
            ),
          ),
          image: _dropIcon!,
          iconSize: 0.95,
          iconAnchor: mapbox.IconAnchor.BOTTOM,
          textField: 'Dropoff',
          textOffset: [0, 1.1],
          textSize: 11,
          textColor: Colors.red.shade900.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
        ),
      );
    }

    final map = _map;
    if (map == null) return;

    final centerLat = lat ?? req?.pickupLatitude ?? 33.8938;
    final centerLng = lng ?? req?.pickupLongitude ?? 35.5018;
    await map.easeTo(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(centerLng, centerLat),
        ),
        zoom: req != null ? 12.0 : 11.0,
      ),
      mapbox.MapAnimationOptions(duration: 450),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.driverLatitude ?? 33.8938;
    final lng = widget.driverLongitude ?? 35.5018;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: SizedBox.expand(
        child: mapbox.MapWidget(
          onMapCreated: _onMapCreated,
          cameraOptions: mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(lng, lat),
            ),
            zoom: 11,
          ),
          styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
        ),
      ),
    );
  }
}
