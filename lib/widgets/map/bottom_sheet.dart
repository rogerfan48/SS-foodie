import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomSheet extends StatelessWidget {
  const BottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.2))],
        ),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantDetailViewModel vm) {
    final restaurant = vm.restaurant;
    if (restaurant == null) {
      return const Center(child: Text('Failed to load details.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(restaurant.restaurantName, style: Theme.of(context).textTheme.headlineSmall),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  context.go('/map/restaurant/${vm.restaurantId}/info');
                },
              ),
            ],
          ),
          // 您可以根據您的設計圖，在這裡顯示更多來自 `restaurant` 物件的預覽資訊
        ],
      ),
    );
  }
}
