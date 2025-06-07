import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class DishItem {
  String? dishId;
  String? dishName;
  int? rating, price;
  String? mainImgURL, genre;

  DishItem({
    required this.dishId,
    required this.dishName,
    required this.price,
    required this.mainImgURL,
    required this.genre,
    required this.rating,
  });
}

class MenuPageViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;

  StreamSubscription<Map<String, RestaurantModel>>? _restaurantSubscription;
  StreamSubscription<Map<String, ReviewModel>>? _reviewSubscription;
  final String restaurantId;
  final List<DishItem> _menuItems = [];
  List<ReviewModel> _reviews = [];

  List<DishItem> get menuItems => _menuItems;

  MenuPageViewModel(this.restaurantId, this._restaurantRepository, this._reviewRepository) {
    _reviewSubscription = _reviewRepository.streamReviewMap().listen((allReviews) {
      _reviews = allReviews.values.where((r) => r.restaurantID == restaurantId).toList();
      // 評論更新後，菜單項目的評分和圖片可能需要更新，因此重新加載菜單
      _loadMenu();
      notifyListeners();
    });

    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((allRestaurants) {
      _loadMenu(allRestaurants);
      notifyListeners();
    });
  }

  void _loadMenu([Map<String, RestaurantModel>? allRestaurants]) {
    // 確保在 restaurant stream 觸發時也能更新
    if (allRestaurants != null && allRestaurants.containsKey(restaurantId)) {
      final restaurant = allRestaurants[restaurantId]!;
      _menuItems.clear();
      restaurant.menuMap.forEach((dishId, dish) {
        _menuItems.add(
          DishItem(
            dishId: dishId,
            dishName: dish.dishName,
            price: dish.dishPrice,
            mainImgURL: calculateMainImgURL(dishId),
            genre: dish.dishGenre,
            rating: calculateRating(dishId),
          ),
        );
      });
    }
  }

  String calculateMainImgURL(String dishId) {
    final dishReviews = _reviews.where((review) => review.dishID == dishId).toList();
    final imgURLs = dishReviews.expand((review) => review.reviewImgURLs).toList();
    return imgURLs.isNotEmpty ? imgURLs.first : '';
  }

  int calculateRating(String dishId) {
    final dishReviews = _reviews.where((review) => review.dishID == dishId).toList();
    if (dishReviews.isEmpty) return 0;
    final total = dishReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return (total / dishReviews.length).round();
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}
