import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodie/models/dish_model.dart';
import 'package:foodie/view_models/write_review_vm.dart';
import 'package:foodie/widgets/restaurant/star_rating_input.dart';
import 'package:provider/provider.dart';

class RestaurantWriteReviewPage extends StatelessWidget {
  const RestaurantWriteReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WriteReviewViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Dialog.fullscreen(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Write a Review'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Specific review', style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                // 動態生成菜色評論區塊
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: vm.specificReviews.length,
                  separatorBuilder: (context, index) => const Divider(height: 32),
                  itemBuilder: (context, index) => _buildSpecificReviewForm(context, vm, index),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add another "Specific review"'),
                  onPressed: vm.addSpecificReview,
                ),
                const Divider(height: 48),
                // 整體評論區塊
                Text('Overall', style: textTheme.headlineSmall),
                const SizedBox(height: 16),
                Center(
                  child: StarRatingInput(
                    rating: vm.overallRating,
                    onRatingChanged: vm.setOverallRating,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: vm.overallContentController,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const Divider(height: 48),
                // 價格區塊
                Text('Price', style: textTheme.headlineSmall),
                const SizedBox(height: 16),
                _buildPriceSelector(context, vm),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                vm.submitReview();
                Navigator.of(context).pop(); // 提交後關閉頁面
              },
              child: Text(
                'Submit',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 輔助方法：建立單一菜色評論的表單
  Widget _buildSpecificReviewForm(BuildContext context, WriteReviewViewModel vm, int index) {
    final state = vm.specificReviews[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.selectedDish?.dishName ?? 'Select Menu Item'),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                onPressed: () async {
                  // 彈出菜單選擇器
                  final DishModel? selectedDish = await showModalBottomSheet(
                    context: context,
                    builder: (_) => _buildDishSelector(context, vm.categorizedMenu),
                  );
                  if (selectedDish != null) {
                    vm.setDish(index, selectedDish);
                  }
                },
              ),
            ),
            // ✅ 只有在有多於一筆菜色評論時才顯示刪除按鈕
            if (vm.specificReviews.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => vm.removeSpecificReview(index),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: StarRatingInput(
            rating: state.rating,
            onRatingChanged: (rating) => vm.setDishRating(index, rating),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.contentController,
          decoration: const InputDecoration(
            hintText: 'Describe the food',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Upload pictures'),
          onPressed: () => vm.pickImages(index),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: state.images.isEmpty ? 0 : 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.images.length,
            itemBuilder: (context, imageIndex) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(state.images[imageIndex].path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.black54, size: 20),
                        onPressed: () => vm.removeImage(index, imageIndex),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 輔助方法：建立價格選擇器
  Widget _buildPriceSelector(BuildContext context, WriteReviewViewModel vm) {
    final prices = {1: '\$', 2: '\$\$', 3: '\$\$\$', 4: '\$\$\$\$'};
    return Wrap(
      spacing: 8.0,
      children:
          prices.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.value),
              selected: vm.selectedPrice == entry.key,
              onSelected: (selected) {
                if (selected) vm.setPrice(entry.key);
              },
            );
          }).toList(),
    );
  }

  // 輔助方法：建立菜色選擇器的內容
  Widget _buildDishSelector(BuildContext context, Map<String, List<DishModel>> menu) {
    return ListView.builder(
      itemCount: menu.keys.length,
      itemBuilder: (context, index) {
        final category = menu.keys.elementAt(index);
        final dishes = menu[category]!;
        return ExpansionTile(
          title: Text(category),
          children:
              dishes
                  .map(
                    (dish) => ListTile(
                      title: Text(dish.dishName),
                      onTap: () => Navigator.of(context).pop(dish),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
