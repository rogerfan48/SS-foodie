import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPositionService extends ChangeNotifier {
  LatLng _position = const LatLng(24.7956, 120.9936);
  String? _id;

  LatLng get position => _position;
  String? get id => _id;

  void updatePosition(LatLng position) {
    _position = position;
    notifyListeners();
  }

  void updateId(String? id) {
    _id = id;
    notifyListeners();
  }
}
