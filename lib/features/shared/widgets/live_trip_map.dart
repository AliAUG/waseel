import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveTripMap extends StatelessWidget {
  const LiveTripMap({
    super.key,
    required this.primaryPoint,
    required this.secondaryPoint,
    this.primaryLabel = 'You',
    this.secondaryLabel = 'Other',
    this.destinationPoint,
    this.destinationLabel = 'Destination',
  });

  final LatLng primaryPoint;
  final LatLng secondaryPoint;
  final String primaryLabel;
  final String secondaryLabel;
  final LatLng? destinationPoint;
  final String destinationLabel;

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[
      primaryPoint,
      secondaryPoint,
      if (destinationPoint != null) destinationPoint!,
    ];
    final center = _centerFromPoints(points);

    final markers = <Marker>[
      _marker(primaryPoint, Icons.navigation, Colors.blue, primaryLabel),
      _marker(secondaryPoint, Icons.person_pin_circle, Colors.red, secondaryLabel),
      if (destinationPoint != null)
        _marker(destinationPoint!, Icons.flag, Colors.green, destinationLabel),
    ];
    final polylines = <Polyline>[
      Polyline(
        points: [primaryPoint, secondaryPoint],
        strokeWidth: 4,
        color: Colors.blue,
      ),
      if (destinationPoint != null)
        Polyline(
          points: [secondaryPoint, destinationPoint!],
          strokeWidth: 4,
          color: Colors.green,
        ),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
          onMapReady: () {
            // Keep default zoom; route line and markers are visible without API keys.
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.waseel.app',
          ),
          PolylineLayer(polylines: polylines),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  Marker _marker(
    LatLng point,
    IconData icon,
    Color color,
    String label,
  ) {
    return Marker(
      point: point,
      width: 100,
      height: 40,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LatLng _centerFromPoints(List<LatLng> points) {
    var sumLat = 0.0;
    var sumLng = 0.0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}
