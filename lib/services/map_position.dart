import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPositionService extends ChangeNotifier {
  LatLng _position = const LatLng(24.7956, 120.9936);

  LatLng get position => _position;

  void updatePosition(LatLng newPos) {
    _position = newPos;
    notifyListeners();
  }
}
