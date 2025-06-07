import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:provider/provider.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final categories = vm.categorizedMenu;

    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No menu items available')),
      );
    }

    final categoryList = categories.keys.toList();

    // Create a GlobalKey for each category if not already present.
    for (final cat in categoryList) {
      _categoryKeys.putIfAbsent(cat, () => GlobalKey());
    }

    return Scaffold(
      body: Column(
        children: [
          // Horizontally scrolling category buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: categoryList.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final keyContext = _categoryKeys[cat]?.currentContext;
                      if (keyContext != null) {
                        Scrollable.ensureVisible(
                          keyContext,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    },
                    child: Text(cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sections for each category
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: categoryList.map((catName) {
                  final catDishes = categories[catName]!;
                  return Container(
                    key: _categoryKeys[catName],
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          catName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            for (int dishIndex = 0; dishIndex < catDishes.length; dishIndex++) ...[
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/dish-detail',
                                    arguments: {
                                      'restaurantId': vm.restaurant?.restaurantId,
                                      'dishName': catDishes[dishIndex].dishName,
                                    },
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                catDishes[dishIndex].dishName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '\$${catDishes[dishIndex].dishPrice}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (catDishes[dishIndex].bestReviewSummary.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              catDishes[dishIndex].bestReviewSummary,
                                              style:
                                                  Theme.of(context).textTheme.bodyMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(), // Add a divider below each dish
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
