class DishModel {
  final String dishName;
  final String veganTag;
  final String halalTag;
  final String dishGenre;
  final int dishPrice;
  final String summary;
  final String bestReviewSummary;
  final List<String> dishReviewIDs;

  DishModel({
    required this.dishName,
    required this.veganTag,
    required this.halalTag,
    required this.dishGenre,
    required this.dishPrice,
    String? summary,
    String? bestReviewSummary,
    List<String>? dishReviewIDs,
  }) : summary = summary ?? '',
        bestReviewSummary = bestReviewSummary ?? '',
        dishReviewIDs = dishReviewIDs ?? [];
      
  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      dishName: map['dishName'] as String,
      veganTag: map['veganTag'] as String,
      halalTag: map['halalTag'] as String,
      dishGenre: map['dishGenre'] as String,
      dishPrice: map['dishPrice'] as int,
      summary: map['summary'] as String? ?? '',
      bestReviewSummary: map['bestReviewSummary'] as String? ?? '',
      dishReviewIDs: List<String>.from(map['dishReviewIDs'] ?? []),
    );
  }
  
}