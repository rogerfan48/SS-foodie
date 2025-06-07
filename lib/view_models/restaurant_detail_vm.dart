import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/enums/vegan_tag.dart';
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

  int get averageRating => _calculateRating();
  int get averagePriceLevel => _calculatePriceLevel();
  VeganTag get overallVeganTag => _calculateVeganTag();
  List<String> get displayImageUrls => _getImageURLs();

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
    if (_restaurant != null && _isLoading) {
      _isLoading = false;
    }
  }

  VeganTag _calculateVeganTag() {
    if (_restaurant == null) return veganTags[VeganTags.nonVegetarian]!;
    final tags = _restaurant!.menuMap.values
        .map((dish) => dish.veganTag)
        .map((tag) => VeganTag.fromString(tag))
        .toList();

    if (tags.isEmpty) return veganTags[VeganTags.nonVegetarian]!;
    if (tags.any((t) => t.title == veganTags[VeganTags.nonVegetarian]!.title)) return veganTags[VeganTags.nonVegetarian]!;
    if (tags.any((t) => t.title == veganTags[VeganTags.vegetarian]!.title)) return veganTags[VeganTags.vegetarian]!;
    if (tags.any((t) => t.title == veganTags[VeganTags.lacto]!.title)) return veganTags[VeganTags.lacto]!;
    if (tags.any((t) => t.title == veganTags[VeganTags.veganPartial]!.title)) return veganTags[VeganTags.veganPartial]!;
    return veganTags[VeganTags.vegan]!;
  }

  int _calculateRating() {
    if (_reviews.isEmpty) return 0; // 沒有評論則返回 0 顆星
    final total = _reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return (total / _reviews.length).round();
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
