import 'package:foodie/models/user.dart';

class Review {
  User? reviewer;
  String? content;
  int? agree, disagree, rating;
  DateTime? date;
  List<String>? reviewImgURLs;
}
