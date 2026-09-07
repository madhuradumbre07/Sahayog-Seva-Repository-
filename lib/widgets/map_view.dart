import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AppMapView extends StatelessWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final Function(LatLng)? onTap;

  const AppMapView({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers = const [],
    this.polylines = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: initialZoom,
        onTap: (tapPosition, point) {
          if (onTap != null) onTap!(point);
        },
      ),
      children: [
        // Free OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sahayogseva.app',
        ),
        // Renders polyline routes between points
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        // Renders pins for customers/workers
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}
