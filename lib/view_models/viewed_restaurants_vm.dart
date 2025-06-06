
import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';

class ViewedRestaurant {
  DateTime? viewDate;
  String? restaurantName;
  GenreTag? genreTag;
}

class ViewRestaurantsViewModel with ChangeNotifier {
  final List<ViewedRestaurant> _viewedRestaurants = [];

  List<ViewedRestaurant> get viewedRestaurants => _viewedRestaurants;

  void addViewedRestaurant(ViewedRestaurant restaurant) {
    _viewedRestaurants.add(restaurant);
    notifyListeners();
  }

  void removeViewedRestaurant(ViewedRestaurant restaurant) {
    _viewedRestaurants.remove(restaurant);
    notifyListeners();
  }

  void clearViewedRestaurants() {
    _viewedRestaurants.clear();
    notifyListeners();
  }
}