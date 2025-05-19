enum VegenTags {
  lactoOvo,        // 蛋奶素
  partialLactoOvo, // 蛋奶素
  vegan,           // 全素
  partialVegan,    // 全素
  nonVegan,        // 葷食
}

class VegenTag{
  const VegenTag(this.title);

  final String title;
}
