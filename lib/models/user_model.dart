class UserModel {
  final String userName;
  final Map<String, String> viewedRestaurantIDs; // (ID, viewDate)
  final List<String> userReviewIDs;

  UserModel({
    required this.userName,
    Map<String, String>? viewedRestaurantIDs,
    List<String>? userReviewIDs,
  })  : viewedRestaurantIDs = viewedRestaurantIDs ?? {},
        userReviewIDs     = userReviewIDs     ?? [];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['userName'] as String,
      viewedRestaurantIDs: Map<String, String>.from(map['viewedRestaurantIDs'] ?? {}),
      userReviewIDs: List<String>.from(map['userReviewIDs'] ?? []),
    );
  }
}

