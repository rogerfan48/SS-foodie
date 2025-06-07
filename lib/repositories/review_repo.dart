import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/review_model.dart';

class ReviewRepository {
  ReviewRepository._internal();
  static final ReviewRepository _instance = ReviewRepository._internal();
  factory ReviewRepository() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);

  Stream<Map<String, ReviewModel>?> streamReviewMap() {
    return _db
      .collection('apps/foodie/reviews')
      .snapshots()
      .map((snapshot) {
        return Map.fromEntries(
          snapshot.docs.map((doc) => MapEntry(
            doc.id,
            ReviewModel.fromMap(doc.data()),
          )),
        );
      });
  }
}
