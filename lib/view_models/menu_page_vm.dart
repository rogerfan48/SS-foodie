import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class DishItem {
  String? dishName;
  int? rating, price;
  String? mainImgURL, genre;

  DishItem({
    required this.dishName,
    required this.price,
    required this.mainImgURL,
    required this.genre,
    required this.rating,
  });
}

class MenuPageViewModel with ChangeNotifier {
  RestaurantRepository _restaurantRepository = RestaurantRepository();
  ReviewRepository _reviewRepository = ReviewRepository();
  StreamSubscription<Map<String, RestaurantModel>>? _restaurantSubscription;
  StreamSubscription<Map<String, ReviewModel>?>? _reviewSubscription;
  final String restaurantId;
  final List<DishItem> _menuItems = [];
  late List<ReviewModel> _reviews;


  List<DishItem> get menuItems => _menuItems;

  MenuPageViewModel(this.restaurantId) {
    _reviewSubscription = _reviewRepository.streamReviewMap().listen(
      (allReviews) {
        _reviews = allReviews?.values
            .where((r) => r.restaurantID == restaurantId)
            .toList() ?? [];
        notifyListeners();
      },
    );

    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen(
      (allRestaurants) {
        if (allRestaurants.containsKey(restaurantId)) {
          final restaurant = allRestaurants[restaurantId]!;
          _menuItems.clear();
          restaurant.menuMap.forEach((dishId, dish) {
            _menuItems.add(DishItem(
              dishName: dish.dishName,
              price: dish.dishPrice,
              mainImgURL: calculateMainImgURL(dishId),
              genre: dish.dishGenre,
              rating: calculateRating(dishId),
            ));
          });
        }
        else {
            _menuItems.clear();
            throw Exception('Restaurant with docId $restaurantId not found');
        }
        notifyListeners();
      },
    );
  }

  String calculateMainImgURL(String dishId) {
    final dishReviews = _reviews
      .where((review) => review.dishID == dishId)
      .toList();

    final imgURLs = dishReviews
      .expand((review) => review.reviewImgURLs)
      .toList();
    
    if (imgURLs.isNotEmpty) {
      return imgURLs.first; // Return the first image URL
    } else {
      return ''; // Return an empty string if no images are available
    }
  }

  int calculateRating(String dishId) {
    final dishReviews = _reviews
      .where((review) => review.dishID == dishId)
      .toList();

    if (dishReviews.isEmpty) return 0;

    final total = dishReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return (total / dishReviews.length).round();
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }

  void addMenuItem(String item) {
    notifyListeners();
  }

  void removeMenuItem(String item) {
    _menuItems.remove(item);
    notifyListeners();
  }

  void clearMenu() {
    _menuItems.clear();
    notifyListeners();
  }
}