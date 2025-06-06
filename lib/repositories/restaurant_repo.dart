import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/dish_model.dart';

class RestaurantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final timeout = const Duration(seconds: 10);

  /// Streams a map where each key is a restaurant doc ID
  /// and each value is the RestaurantModel (with its menu loaded).
  Stream<Map<String, RestaurantModel>> streamRestaurantMap() {
    return _db
      .collection('apps/foodie/restaurants')
      .snapshots()
      .asyncMap((snapshot) async {
        final entries = await Future.wait(snapshot.docs.map((doc) async { // each doc is a restaurant
          final data = doc.data();
          final menuSnap = await doc.reference.collection('menu').get();
          final menuMap = {
            for (var dish in menuSnap.docs)
              dish.id: DishModel.fromMap(dish.data()),
          };
          final restaurant = RestaurantModel(
            restaurantName:        data['restaurantName']      as String,
            summary:               data['summary']             as String,
            genreTags:             List<String>.from(data['genreTags'] as List),
            businessHour:          Map<String, String>.from(data['businessHour'] as Map),
            phoneNumber:           data['phoneNumber']         as String,
            address:               data['address']             as String,
            latitude:              data['latitude']            as double,
            longtitude:            data['longtitude']          as double,
            menuMap:               menuMap,
            restaurantReviewIDs:   List<String>.from(data['restaurantReviewIDs'] ?? []),
          );
          return MapEntry(doc.id, restaurant);
        }));
        return Map.fromEntries(entries);
      });
  }
}