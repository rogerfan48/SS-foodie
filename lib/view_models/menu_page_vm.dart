import 'package:flutter/widgets.dart';

class DishItem {
  String? dishName;
  int? rating, price;
  String? mainImgURL, genre;

  DishItem({
    this.dishName,
    this.price,
  });
}

class MenuPageViewModel with ChangeNotifier {
  final List<String> _menuItems = [];

  List<String> get menuItems => _menuItems;

  void addMenuItem(String item) {
    _menuItems.add(item);
    notifyListeners();
  }

  void removeMenuItem(String item) {
    _menuItems.remove(item);
    notifyListeners();
  }

  void clearMenu() {
    _menuItems.clear();
    notifyListeners();
  }
}