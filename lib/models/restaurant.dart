import 'package:foodie/models/menu.dart';
import 'package:foodie/models/restaurant_info.dart';
import 'package:foodie/models/restaurant_review.dart';

class Restaurant {
  String? name;
  RestaurantInfo? info;
  Menu? menu;
  List<RestaurantReview>? reviews;
}
