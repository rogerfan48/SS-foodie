
import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/halal_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';

class RestaurantInfo {
  String? restaurantName;
  String? summary;
  String? address;
  String? phoneNumber;
  Map<String, String>? businessHour;
  List<String>? imageURLs;
  List<GenreTag>? genreTags;
  VeganTag? veganTag;
  HalalTag? halalTag;
  int? priceLevel, rating;

  RestaurantInfo({
    this.restaurantName,
    this.summary,
    this.address,
    this.phoneNumber,
    this.businessHour,
  });
}

class InfoPageViewModel with ChangeNotifier {
  RestaurantInfo? _restaurantInfo;

  RestaurantInfo? get restaurantInfo => _restaurantInfo;

  void updateInfoText() {
    notifyListeners();
  }
}