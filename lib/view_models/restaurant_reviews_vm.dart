import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';

class RestaurantReview {
  String? restaurantName, content, reviewDate, reviewerID, restaurantID;
  int? priceLevel, rating, agree, disagree;
  List<String>? imageURLs;

  RestaurantReview({
    this.restaurantName,
    this.content,
    this.reviewDate,
    this.reviewerID,
    this.restaurantID,
    this.priceLevel,
    this.rating,
    this.agree,
    this.disagree,
    this.imageURLs,
  });
}

class RestaurantReviewsViewModel with ChangeNotifier {
  // 透過建構子注入依賴
  final String restaurantId;
  final RestaurantRepository _restaurantRepository;
  final ReviewRepository _reviewRepository;

  // 用於管理數據流的訂閱
  late final StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;
  late final StreamSubscription<Map<String, ReviewModel>> _reviewSubscription;

  // ViewModel 的內部狀態
  String _restaurantName = '';
  final List<RestaurantReview> _reviews = [];

  // 向 UI 公開的數據
  List<RestaurantReview> get reviews => _reviews;
  String get restaurantName => _restaurantName;

  // 透過建構子接收 restaurantId 和需要的 Repositories
  RestaurantReviewsViewModel(this.restaurantId, this._restaurantRepository, this._reviewRepository) {
    // 監聽餐廳數據流以獲取餐廳名稱
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      if (restaurantMap.containsKey(restaurantId)) {
        final name = restaurantMap[restaurantId]!.restaurantName;
        if (name != _restaurantName) {
          _restaurantName = name;
          notifyListeners(); // 名稱更新時通知 UI
        }
      }
    });

    // 監聽評論數據流以獲取相關評論
    _reviewSubscription = _reviewRepository.streamReviewMap().listen((reviewMap) {
      _reviews.clear();
      reviewMap.values
        .where((review) => review.restaurantID == restaurantId) // 過濾出這家餐廳的評論
        .forEach((review) {
          _reviews.add(RestaurantReview(
            restaurantName: _restaurantName, // 使用已獲取的餐廳名稱
            content: review.content,
            reviewDate: review.reviewDate,
            reviewerID: review.reviewerID,
            restaurantID: review.restaurantID,
            priceLevel: review.priceLevel,
            rating: review.rating,
            agree: review.agree,
            disagree: review.disagree,
            imageURLs: review.reviewImgURLs,
          ));
        });
      
      // 排序，例如按日期降序
      _reviews.sort((a, b) => DateTime.parse(b.reviewDate!).compareTo(DateTime.parse(a.reviewDate!)));
      
      notifyListeners(); // 評論列表更新後通知 UI
    });
  }

  // 清理資源，防止記憶體洩漏
  @override
  void dispose() {
    _restaurantSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }
}
