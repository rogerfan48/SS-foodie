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
  const VeganTag(this.title, this.icon);

  final String title;
  final Icon icon;
}

const veganTags = {
  VeganTags.vegan: true, // TODO:
};
