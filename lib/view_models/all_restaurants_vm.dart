
import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';

class RestaurantItem {
  String? restaurantName;
  double? latitude, longitude;
  GenreTag? genreTag;

  RestaurantItem({
    this.restaurantName,
  });
}

class AllRestaurantViewModel with ChangeNotifier{
  final List<RestaurantItem> _restaurants = [];

  List<RestaurantItem> get restaurants => _restaurants;

  void addRestaurant(RestaurantItem restaurant) {
    _restaurants.add(restaurant);
    notifyListeners();
  }

  void removeRestaurant(RestaurantItem restaurant) {
    _restaurants.remove(restaurant);
    notifyListeners();
  }

  void clearRestaurants() {
    _restaurants.clear();
    notifyListeners();
  }
}