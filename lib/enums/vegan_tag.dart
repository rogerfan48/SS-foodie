import 'package:flutter/material.dart';

enum VeganTags {
  vegan, // 全素
  veganPartial,
  lactoOvo, // 蛋奶素
  lactoOvoPartial,
  vegetarian, // 五辛素
  vegetarianPartial,
  nonVegetarian, // 葷食
}

class VeganTag {
  const VeganTag(this.title, this.image);

  final String title;
  final Image image;
}

final veganTags = {
  VeganTags.vegan: ("Vegan", Image.asset('assets/imgs/leaf.png', width: 150)), 
  VeganTags.veganPartial: VeganTag("VeganPartial", Image.asset('assets/imgs/leaf.png', width: 150)),
  VeganTags.lactoOvo: VeganTag("LactoOvo", Image.asset('assets/imgs/milk.png', width: 150)),  
  VeganTags.lactoOvoPartial: VeganTag("LactoOvoPartial", Image.asset('assets/imgs/milk.png', width: 150)),
  VeganTags.vegetarian: VeganTag("Vegetarian", Image.asset('assets/imgs/onion.png', width: 150)),
  VeganTags.vegetarianPartial: VeganTag("VegetarianPartial", Image.asset('assets/imgs/onion.png', width: 150)),
  VeganTags.nonVegetarian: VeganTag("NonVegetarian", Image.asset('assets/imgs/meat.png', width: 150)),
};
