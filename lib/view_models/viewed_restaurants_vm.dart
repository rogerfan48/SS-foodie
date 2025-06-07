import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/user_repo.dart';

class ViewedRestaurant {
  DateTime? viewDate;
  String? restaurantName;
  GenreTag? genreTag;
}

class ViewedRestaurantsViewModel with ChangeNotifier {
  final String _userId;
  final UserRepository _userRepository;
  final RestaurantRepository _restaurantRepository;
  
  late StreamSubscription<Map<String, UserModel>> _userSubscription;
  late StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;

  Map<String, List<String>> idDateMap = {};
  final List<ViewedRestaurant> _viewedRestaurants = [];
  List<ViewedRestaurant> get viewedRestaurants => _viewedRestaurants;

  ViewedRestaurantsViewModel(
    this._userId,
    this._userRepository,
    this._restaurantRepository,
  ) {
    _userSubscription = _userRepository.streamUserMap().listen((allUsers) {
      final user = allUsers[_userId];
      if (user != null) {
        idDateMap = user.viewedRestaurantIDs;
        // 重新觸發餐廳的讀取，因為用戶數據可能已更新
        _loadRestaurants();
      }
    });

    _restaurantSubscription = _restaurantRepository
      .streamRestaurantMap()
      .listen((allRestaurants) {
        _loadRestaurants(allRestaurants);
      });
  }

  void _loadRestaurants([Map<String, RestaurantModel>? allRestaurants]) {
    // 確保在 restaurant stream 觸發時也能更新
    if (allRestaurants != null) {
      _viewedRestaurants.clear();
      idDateMap.forEach((restId, dateList) {
        final r = allRestaurants[restId];
        if (r != null) {
          for (final dateString in dateList) {
            _viewedRestaurants.add(ViewedRestaurant()
              ..viewDate       = DateTime.parse(dateString)
              ..restaurantName = r.restaurantName
              ..genreTag       = GenreTag.fromString(r.genreTags.first)
            );
          }
        }
      });
      notifyListeners();
    }
  }

  Future<void> deleteViewedRestaurant(String restaurantId) async {
    if (idDateMap.containsKey(restaurantId)) {
      idDateMap.remove(restaurantId);
      await _userRepository.updateUserViewedRestaurants(_userId, idDateMap);
    }
  }

  Future<void> addViewedRestaurant(String restaurantId, DateTime viewDate) async {
    final dateString = viewDate.toIso8601String();
    idDateMap.update(
      restaurantId,
      (list) => [...list, dateString],
      ifAbsent: () => [dateString],
    );
    await _userRepository.updateUserViewedRestaurants(_userId, idDateMap);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _restaurantSubscription.cancel();
    super.dispose();
  }
}