import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final CameraPosition initialPosition;

  const GoogleMapWidget({
    Key? key,
    required this.markers,
    required this.initialPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // initialCameraPosition: initialPosition,
      // markers: markers,
      // myLocationEnabled: true,
      // myLocationButtonEnabled: true,
    );
  }
}

