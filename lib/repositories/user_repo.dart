import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);


  Stream<Map<String, UserModel>> streamUserMap() {
    return _db
      .collection('apps/foodie/users')
      .snapshots()
      .map((snapshot) {
        return Map.fromEntries(
          snapshot.docs.map((doc) => MapEntry(
            doc.id,
            UserModel.fromMap(doc.data()),
          )),
        );
      });
  }
}