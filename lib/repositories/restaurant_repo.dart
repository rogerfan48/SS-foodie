import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/dish_model.dart';

class RestaurantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);

  RestaurantRepository();

  Stream<Map<String, RestaurantModel>> streamRestaurantMap() {
    return _db
      .collection('apps/foodie/restaurants')
      .snapshots()
      .asyncMap((snapshot) async {
        final entries = await Future.wait(snapshot.docs.map((doc) async {
          final data   = doc.data();
          final menu   = await doc.reference.collection('menu').get();
          final menuMap = { for (var d in menu.docs) d.id: DishModel.fromMap(d.data()) };
          final restaurant = RestaurantModel(
            restaurantId:        doc.id,                           // ← pass the ID
            restaurantName:      data['restaurantName'] as String,
            summary:             data['summary']       as String,
            genreTags:           List<String>.from(data['genreTags'] as List),
            businessHour:        Map<String, String>.from(data['businessHour'] as Map),
            phoneNumber:         data['phoneNumber']   as String,
            address:             data['address']       as String,
            latitude:            data['latitude']      as double,
            longtitude:          data['longtitude']    as double,
            googleMapURL:        data['googleMapURL']  as String,
            menuMap:             menuMap,
            restaurantReviewIDs: List<String>.from(data['restaurantReviewIDs'] ?? []),
          );
          return MapEntry(doc.id, restaurant);
        }));
        return Map.fromEntries(entries);
      });
  }
}
