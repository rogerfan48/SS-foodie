import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';

enum ReviewSortType { Default, Latest, Highest, Lowest }

class RestaurantDetailViewModel with ChangeNotifier {
  final String restaurantId;
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;
  final UserRepository _userRepository;
  final Map<String, UserModel> _userCache = {};

  StreamSubscription? _restaurantSubscription;
  StreamSubscription? _reviewSubscription;

  late Map<String, List<DishModel>> _categoriezedMenu;
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
        _reviews.sort(
          (a, b) {
            final aUser = a.agreedBy.length + a.disagreedBy.length;
            final bUser = b.agreedBy.length + b.disagreedBy.length;
            return bUser.compareTo(aUser);
          },
        );
        break;
    }
    notifyListeners();
  }

  RestaurantDetailViewModel({
    required this.restaurantId,
    required RestaurantRepository restaurantRepository,
    required ReviewRepository reviewRepository,
    required UserRepository userRepository,
  }) : _restaurantRepository = restaurantRepository,
       _reviewRepository = reviewRepository,
       _userRepository = userRepository {
    _listenToData();
  }

  void _listenToData() {
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      if (restaurantMap.containsKey(restaurantId)) {
        _restaurant = restaurantMap[restaurantId];
        _checkLoadingStatus();
        _buildCategorizedMenu();
        notifyListeners();
      }
    });

    _reviewSubscription = _reviewRepository.streamReviewMap().listen((reviewMap) {
      _reviews = reviewMap.values.where((r) => r.restaurantID == restaurantId).toList();
      sortReviews(_currentSortType);
      _checkLoadingStatus();
      notifyListeners();
    });

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

  void _buildCategorizedMenu() {
    _categoriezedMenu = _restaurant?.menuMap.values.fold<Map<String, List<DishModel>>>({}, (map, dish) {
      final category = dish.dishGenre.isNotEmpty ? dish.dishGenre : 'Uncategorized';
      if (!map.containsKey(category)) {
        map[category] = [];
      }
      map[category]!.add(dish);
      return map;
    }) ?? {"test": []};
  }

  Future<UserModel?> getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    try {
      final userDoc = await _userRepository.getUser(userId);
      if (userDoc.exists) {
        final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        _userCache[userId] = user; // 存入快取
        return user;
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> toggleReviewVote({
    required String reviewId,
    required String currentUserId,
    required VoteType voteType,
    required bool isCurrentlyVoted,
  }) async {
    try {
      await _reviewRepository.toggleVote(
        reviewId: reviewId,
        userId: currentUserId,
        voteType: voteType,
        isCurrentlyVoted: isCurrentlyVoted,
      );
    } catch (e) {
      print("Failed to toggle vote: $e");
    }
  }

  @override
  void dispose() {
    _restaurantSubscription?.cancel();
    _reviewSubscription?.cancel();
    super.dispose();
  }
}
