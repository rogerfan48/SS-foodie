import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/halal_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';

class RestaurantInfo {
  String? phoneNumber, address, summary;
  Map<String, String>? businessHours;
  int? rating;
  List<GenreTag>? genreTags;
  HalalTag? halalTags;
  VeganTag? veganTags;
  List<String>? dishImgURLs;
}