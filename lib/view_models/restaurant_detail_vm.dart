import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class RestaurantDetailViewModel with ChangeNotifier {
  final String restaurantId;
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;

  StreamSubscription? _restaurantSubscription;
  StreamSubscription? _reviewSubscription;

  RestaurantModel? _restaurant;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  RestaurantModel? get restaurant => _restaurant;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String get restaurantName => _restaurant?.restaurantName ?? 'Loading...';

  RestaurantDetailViewModel({
    required this.restaurantId,
    required RestaurantRepository restaurantRepository,
    required ReviewRepository reviewRepository,
  })  : _restaurantRepository = restaurantRepository,
        _reviewRepository = reviewRepository {
    _listenToData();
  }

  void _listenToData() {
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      if (restaurantMap.containsKey(restaurantId)) {
        _restaurant = restaurantMap[restaurantId];
        _checkLoadingStatus();
        notifyListeners();
      }
    });

    _reviewSubscription = _reviewRepository.streamReviewMap().listen((reviewMap) {
      _reviews = reviewMap.values.where((r) => r.restaurantID == restaurantId).toList();
      _reviews.sort((a, b) => DateTime.parse(b.reviewDate).compareTo(DateTime.parse(a.reviewDate)));
      _checkLoadingStatus();
      notifyListeners();
    });
  }

  void _checkLoadingStatus() {
    // 只有在 restaurant 數據也載入後才算完成
    if (_restaurant != null && _isLoading) {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}
