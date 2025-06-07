import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

enum ReviewSortType { Default, Latest, Highest, Lowest }

class RestaurantDetailViewModel with ChangeNotifier {
  final String restaurantId;
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;

  StreamSubscription? _restaurantSubscription;
  StreamSubscription? _reviewSubscription;

  Map<String, List<DishModel>> _categoriezedMenu = {};
  RestaurantModel? _restaurant;
  List<ReviewModel> _reviews = [];
  ReviewSortType _currentSortType = ReviewSortType.Default;
  bool _isLoading = true;

  Map<String, List<DishModel>> get categorizedMenu => _categoriezedMenu;
  RestaurantModel? get restaurant => _restaurant;
  List<ReviewModel> get reviews => _reviews;
  ReviewSortType get currentSortType => _currentSortType;
  bool get isLoading => _isLoading;
  String get restaurantName => _restaurant?.restaurantName ?? 'Loading...';

  double get averageRating => _calculateRating();
  int get averagePriceLevel => _calculatePriceLevel();
  VeganTag get overallVeganTag => VeganTag.fromString(_restaurant?.veganTag ?? "nonVegetarian");
  List<String> get displayImageUrls => _getImageURLs();

  Map<int, int> get ratingDistribution {
    final Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _reviews) {
      if (distribution.containsKey(review.rating)) {
        distribution[review.rating] = distribution[review.rating]! + 1;
      }
    }
    return distribution;
  }
  
  void sortReviews(ReviewSortType sortType) {
    _currentSortType = sortType;
    switch (sortType) {
      case ReviewSortType.Highest:
        _reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortType.Lowest:
        _reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case ReviewSortType.Latest:
      default:
        _reviews.sort((a, b) => DateTime.parse(b.reviewDate).compareTo(DateTime.parse(a.reviewDate)));
        break;
    }
    notifyListeners();
  }

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
      sortReviews(_currentSortType);
      _checkLoadingStatus();
      notifyListeners();
    });

    _categoriezedMenu = _restaurant?.menuMap.values.fold<Map<String, List<DishModel>>>({}, (map, dish) {
      final category = dish.dishGenre.isNotEmpty ? dish.dishGenre : 'Uncategorized';
      if (!map.containsKey(category)) {
        map[category] = [];
      }
      map[category]!.add(dish);
      return map;
    }) ?? {};
  }

  void _checkLoadingStatus() {
    if (_restaurant != null && _isLoading) {
      _isLoading = false;
    }
  }

  double _calculateRating() {
    if (_reviews.isEmpty) return 0; // 沒有評論則返回 0 顆星
    final total = _reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return (total / _reviews.length);
  }

  int _calculatePriceLevel() {
    if (_reviews.isEmpty) return 1; // 預設為 1
    final validReviews = _reviews.where((r) => r.priceLevel != null).toList();
    if (validReviews.isEmpty) return 1;
    final total = validReviews.fold<int>(0, (sum, review) => sum + review.priceLevel!);
    return (total / validReviews.length).round().clamp(1, 5); // 確保價格等級在 1-5 之間
  }

  List<String> _getImageURLs() {
    if (_reviews.isEmpty) return [];
    return _reviews.expand((review) => review.reviewImgURLs).toList();
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}
