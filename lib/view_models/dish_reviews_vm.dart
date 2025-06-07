import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class DishReview {
  String? dishName, content, reviewDate, reviewerID, restaurantID, dishID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;

  DishReview({
    this.dishName, this.content, this.reviewDate, this.reviewerID, 
    this.restaurantID, this.dishID, this.priceLevel, this.rating, 
    this.agree, this.disagree, List<String>? imageURLs,
  }) : imageURLs = imageURLs ?? [];
}

class DishReviewsViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;

  late final StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;
  late final StreamSubscription<Map<String, ReviewModel>> _reviewSubscription;
  
  String _dishName = ''; // 初始化為空字串，避免 bug
  final List<DishReview> _reviews = [];
  List<DishReview> get reviews => _reviews;

  DishReviewsViewModel(this._restaurantRepository, this._reviewRepository, String restaurantId, String dishId) {
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen(
      (restaurantMap) {
        final newName = restaurantMap[restaurantId]?.menuMap[dishId]?.dishName ?? "Unknown Dish";
        if(newName != _dishName) {
          _dishName = newName;
          // 菜名更新後，需要更新現有評論列表中的菜名
          for (var review in _reviews) {
            review.dishName = _dishName;
          }
          notifyListeners();
        }
    });

    _reviewSubscription = _reviewRepository.streamReviewMap().listen((reviewMap) {
        if (reviewMap == null) return;
        _reviews.clear();
        reviewMap.forEach((id, review) {
          // 只加入符合 restaurantId 和 dishId 的評論
          if (review.restaurantID == restaurantId && review.dishID == dishId) {
            _reviews.add(DishReview(
              dishName: _dishName, // 使用已經獲取到的菜名
              content: review.content,
              reviewDate: review.reviewDate,
              reviewerID: review.reviewerID,
              restaurantID: review.restaurantID,
              dishID: review.dishID,
              priceLevel: review.priceLevel,
              rating: review.rating,
              agree: review.agree,
              disagree: review.disagree,
              imageURLs: List<String>.from(review.reviewImgURLs),
            ));
          }
        });
        notifyListeners();
    });
  }

  @override
  void dispose() {
    _restaurantSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }
}
