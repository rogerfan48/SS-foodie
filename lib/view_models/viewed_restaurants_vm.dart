import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/user_repo.dart';

class ViewedRestaurant {
  DateTime? viewDate;
  String? restaurantName;
  GenreTag? genreTag;
}

class ViewRestaurantsViewModel with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  late StreamSubscription<Map<String, UserModel>?> _userSubscription;
  late StreamSubscription<Map<String, RestaurantModel>?> _restaurantSubscription;

  // holds <restaurantId, viewDateString>
  late Map<String, String> idDateMap;

  final List<ViewedRestaurant> _viewedRestaurants = [];
  List<ViewedRestaurant> get viewedRestaurants => _viewedRestaurants;

  ViewRestaurantsViewModel(String userId) {
    _userSubscription = _userRepository.streamUserMap().listen((allUsers) {
      final user = allUsers[userId];
      if (user != null) {
        idDateMap = user.viewedRestaurantIDs;
      }
    });

    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((allRestaurants) {
      _viewedRestaurants.clear();
      // only include restaurants in idDateMap
      idDateMap.forEach((restId, dateString) {
        final r = allRestaurants[restId];
        if (r != null) {
          _viewedRestaurants.add(ViewedRestaurant()
            ..viewDate       = DateTime.parse(dateString)
            ..restaurantName = r.restaurantName
            ..genreTag       = GenreTag.fromString(r.genreTags.first)
          );
        }
      });
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _restaurantSubscription.cancel();
    super.dispose();
  }

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