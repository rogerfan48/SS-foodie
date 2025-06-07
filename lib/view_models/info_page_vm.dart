import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class RestaurantInfo {
  final String restaurantId;      // ← new
  final String restaurantName;
  final String summary;
  final String address;
  final String phoneNumber;
  final Map<String, String> businessHour;
  final List<String> imageURLs;
  final List<GenreTag> genreTags;
  final VeganTag veganTag;
  final int priceLevel, rating;
  final String? googleMapURL;

  RestaurantInfo({
    required this.restaurantId,   // ← new
    required this.restaurantName,
    required this.summary,
    required this.address,
    required this.phoneNumber,
    required this.businessHour,
    required this.genreTags,
    required this.veganTag,
    required this.priceLevel,
    required this.rating,
    required this.imageURLs,
    this.googleMapURL,
  });
}

class InfoPageViewModel with ChangeNotifier {
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;
  final String _restaurantId;

  RestaurantInfo? _restaurantInfo;
  List<ReviewModel> _restaurantReviews = [];
  RestaurantModel? _restaurant;
  StreamSubscription<Map<String, RestaurantModel>>? _restaurantSubscription;
  StreamSubscription<Map<String, ReviewModel>>? _reviewSubscription;

  RestaurantInfo? get restaurantInfo => _restaurantInfo;

  InfoPageViewModel(this._restaurantId, this._restaurantRepository, this._reviewRepository) {
    _reviewSubscription = _reviewRepository.streamReviewMap().listen((allReviews) {
      _restaurantReviews = allReviews.values
          .where((r) => r.restaurantID == _restaurantId)
          .toList();
      _updateRestaurantInfo();
      notifyListeners();
    });

    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      if (restaurantMap.containsKey(_restaurantId)) {
        _restaurant = restaurantMap[_restaurantId]!;
        _updateRestaurantInfo();
        notifyListeners();
      }
    });
  }

  void _updateRestaurantInfo() {
    if (_restaurant == null) return;
    _restaurantInfo = RestaurantInfo(
      restaurantId:   _restaurant!.restaurantId,        // ← use model’s ID
      restaurantName: _restaurant!.restaurantName,
      summary:        _restaurant!.summary,
      address:        _restaurant!.address,
      phoneNumber:    _restaurant!.phoneNumber,
      businessHour:   _restaurant!.businessHour,
      googleMapURL:   _restaurant!.googleMapURL,
      genreTags:      _restaurant!.genreTags.map(GenreTag.fromString).toList(),
      veganTag:       calculateVeganTag(),
      priceLevel:     calculatePriceLevel(),
      rating:         calculateRating(),
      imageURLs:      getImageURLs(),
    );
  }

  // calculateVeganTag, calculateRating, calculatePriceLevel, getImageURLs 等方法保持不變
  VeganTag calculateVeganTag() {
    if (_restaurant == null) return veganTags[VeganTags.nonVegetarian]!;
    final tags =
        _restaurant!.menuMap.values
            .map((dish) => dish.veganTag)
            .map((tag) => VeganTag.fromString(tag))
            .toList();

    if (tags.isEmpty) return veganTags[VeganTags.nonVegetarian]!;
    if (tags.any((t) => t.title == veganTags[VeganTags.nonVegetarian]!.title)) {
      return veganTags[VeganTags.nonVegetarian]!;
    }
    if (tags.any((t) => t.title == veganTags[VeganTags.vegetarian]!.title)) {
      return veganTags[VeganTags.vegetarian]!;
    }
    if (tags.any((t) => t.title == veganTags[VeganTags.lacto]!.title)) {
      return veganTags[VeganTags.lacto]!;
    }
    if (tags.any((t) => t.title == veganTags[VeganTags.veganPartial]!.title)) {
      return veganTags[VeganTags.veganPartial]!;
    }
    return veganTags[VeganTags.vegan]!;
  }

  int calculateRating() {
    if (_restaurantReviews.isEmpty) return 3;
    final total = _restaurantReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return (total / _restaurantReviews.length).round();
  }

  int calculatePriceLevel() {
    if (_restaurantReviews.isEmpty) return 2;
    final validReviews = _restaurantReviews.where((r) => r.priceLevel != null).toList();
    if (validReviews.isEmpty) return 2;
    final totalPriceLevel = validReviews.fold<int>(0, (sum, review) => sum + review.priceLevel!);
    return (totalPriceLevel / validReviews.length).round();
  }

  List<String> getImageURLs() {
    if (_restaurantReviews.isEmpty) return [];
    return _restaurantReviews.expand((review) => review.reviewImgURLs).toList();
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}
