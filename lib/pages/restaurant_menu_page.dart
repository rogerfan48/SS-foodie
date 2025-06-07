import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/widgets/firebase_image.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  final Map<String, GlobalKey> _categoryKeys = {};

  void _scrollToCategory(int index) {
    final vm = context.read<RestaurantDetailViewModel>();
    final categoryName = vm.categorizedMenu.keys.elementAt(index);
    final keyContext = _categoryKeys[categoryName]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final categories = vm.categorizedMenu;

    if (categories.isEmpty) {
      return const Center(child: Text('No menu items available'));
    }

    final categoryList = categories.keys.toList();

    for (final cat in categoryList) {
      _categoryKeys.putIfAbsent(cat, () => GlobalKey());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: _CategoryHeaderDelegate(
              categoryNames: categoryList,
              selectedIndex: -1,
              onCategorySelected: _scrollToCategory,
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final categoryName = categoryList[index];
                final dishes = categories[categoryName]!;
                return Container(
                  key: _categoryKeys[categoryName],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                        child: Text(categoryName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      ...dishes.asMap().entries.map((entry) {
                        final dishIndex = entry.key;
                        final dish = entry.value;
                        
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                context.go('/map/restaurant/${vm.restaurantId}/menu/${dish.dishId}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                child: Row(
                                  children: [
                                    // 菜色圖片
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: FirebaseImage(
                                        gsUri: null,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dish.dishName, style: Theme.of(context).textTheme.titleMedium),
                                          if (dish.bestReviewSummary.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                dish.bestReviewSummary,
                                                style: Theme.of(context).textTheme.bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // 右側的價格
                                    Text(
                                      '\$${dish.dishPrice}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 只在非最後一個項目下方顯示分隔線
                            if (dishIndex < dishes.length - 1)
                              const Divider(height: 1, indent: 4, endIndent: 4), // 縮排以對齊文字
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
              childCount: categoryList.length,
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categoryNames;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  _CategoryHeaderDelegate({
    required this.categoryNames,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          spacing: 8.0,
          children: List.generate(categoryNames.length, (index) {
            return FilterChip(
              label: Text(categoryNames[index]),
              selected: selectedIndex == index,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(index);
                }
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0; // Header 的最大高度

  @override
  double get minExtent => 56.0; // Header 的最小高度（釘選時的高度）

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // 簡單起見，總是重建
  }
}
