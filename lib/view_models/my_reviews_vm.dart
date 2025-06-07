import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

// 建立一個新的顯示模型，包含餐廳名稱
class MyReviewDisplay {
  final String restaurantName;
  final ReviewModel review;

  MyReviewDisplay({required this.restaurantName, required this.review});
}

class MyReviewViewModel with ChangeNotifier {
  final String _userId;
  final ReviewRepository _reviewRepository;
  final RestaurantRepository _restaurantRepository; // 新增依賴

  late final StreamSubscription<Map<String, ReviewModel>> _reviewSubscription;
  late final StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;

  Map<String, RestaurantModel> _restaurantMap = {};
  final List<MyReviewDisplay> _myReviews = [];

  List<MyReviewDisplay> get myReviews => _myReviews;

  // 透過建構子注入新的依賴
  MyReviewViewModel(this._userId, this._reviewRepository, this._restaurantRepository) {
    // 先監聽餐廳數據
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      _restaurantMap = restaurantMap;
      // 當餐廳數據更新時，可能需要重新整理評論列表以匹配最新名稱
      _updateReviews([]);
    });

    // 再監聽評論數據
    _reviewSubscription = _reviewRepository.streamReviewMap().listen((allReviews) {
      final userReviews = allReviews.values.where((r) => r.reviewerID == _userId).toList();
      _updateReviews(userReviews);
    });
  }

  void _updateReviews(List<ReviewModel> userReviews) {
    _myReviews.clear();
    for (var review in userReviews) {
      // 從已有的餐廳 map 中查找名稱
      final restaurantName =
          _restaurantMap[review.restaurantID]?.restaurantName ?? 'Unknown Restaurant';
      _myReviews.add(MyReviewDisplay(restaurantName: restaurantName, review: review));
    }
    _myReviews.sort(
      (a, b) => DateTime.parse(b.review.reviewDate).compareTo(DateTime.parse(a.review.reviewDate)),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _reviewSubscription.cancel();
    _restaurantSubscription.cancel();
    super.dispose();
  }
}
