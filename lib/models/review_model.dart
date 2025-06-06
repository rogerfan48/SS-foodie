class ReviewModel {
  final String reviewerID;
  final String restaurantID;
  final String? dishID;
  final int agree;
  final int disagree;
  final int rating;
  final int? priceLevel;
  final String content;
  final String reviewDate;
  final List<String> reviewImgURLs;

  ReviewModel({
    required this.reviewerID,
    required this.restaurantID,
    required this.agree,
    required this.disagree,
    required this.rating,
    required this.content,
    required this.reviewDate,
    this.dishID,
    this.priceLevel,
    List<String>? reviewImgURLs,
  }) : reviewImgURLs = reviewImgURLs ?? [];

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewerID: map['reviewerID'] as String,
      restaurantID: map['restaurantID'] as String,
      dishID: map['dishID'] as String?,
      agree: map['agree'] as int,
      disagree: map['disagree'] as int,
      rating: map['rating'] as int,
      priceLevel: map['priceLevel'] as int?,
      content: map['content'] as String,
      reviewDate: map['reviewDate'] as String,
      reviewImgURLs: List<String>.from(map['reviewImgURLs'] ?? []),
    );
  }
}