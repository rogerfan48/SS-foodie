import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/halal_tag.dart';
import 'package:foodie/enums/vegen_tag.dart';
import 'package:foodie/models/menu.dart';
import 'package:foodie/models/restaurant_info.dart';
import 'package:foodie/models/restaurant_review.dart';

class Restaurant {
  String? name, summary;
  int? rating;
  List<GenreTag>? genreTags;
  List<HalalTag>? halalTags;
  List<VegenTag>? vegenTags;
  List<RestaurantReview>? reviews;
  Menu? menu;
  RestaurantInfo? info;

  // Todo: image

}