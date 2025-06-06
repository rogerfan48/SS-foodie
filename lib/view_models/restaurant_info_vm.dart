import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/halal_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';

class RestaurantInfoViewModel with ChangeNotifier {
  List<String>? imgURLs;
  List<GenreTag>? genreTags;
  VeganTag? veganTag;
  HalalTag? halalTag;
  int? priceLevel;
  int? rating;
  String?  address, phoneNumber;
  Map<String, String>? businessHours; 
}