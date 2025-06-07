import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';

class RestaurantItem {
  final String restaurantId;
  final String restaurantName;
  final double latitude, longitude;
  final GenreTag genreTag;
  final VeganTag veganTag;

  RestaurantItem({
    required this.restaurantId,
    required this.restaurantName,
    required this.latitude,
    required this.longitude,
    required this.genreTag,
    required this.veganTag,
  });
}

class AllRestaurantViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository;
  final List<RestaurantItem> _restaurants = [];
  late final StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;

  List<RestaurantItem> get restaurants => _restaurants;

  AllRestaurantViewModel(this._restaurantRepository) {
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      _restaurants.clear();
      restaurantMap.forEach((docId, restaurant) {
        _restaurants.add(
          RestaurantItem(
            restaurantId: docId,
            restaurantName: restaurant.restaurantName,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            genreTag: GenreTag.fromString(restaurant.genreTags.firstOrNull ?? 'others'),
            veganTag: VeganTag.fromString(restaurant.veganTag),
          ),
        );
      });
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _restaurantSubscription.cancel();
    super.dispose();
  }
}
