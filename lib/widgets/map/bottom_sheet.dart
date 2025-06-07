import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';

class BottomSheet extends StatelessWidget {
  const BottomSheet({super.key});

  void _navigateToRestaurantPage(BuildContext context, RestaurantDetailViewModel vm) {
    context.go('/map/restaurant/${vm.restaurantId}/info');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.15))],
      ),
      child:
          vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantDetailViewModel vm) {
    final restaurant = vm.restaurant;
    if (restaurant == null) {
      return const Center(child: Text('Could not load restaurant details.'));
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // details.primaryVelocity < 0 表示向上滑動
        // 速度閾值 -500 可以防止輕微的誤觸
        if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
          _navigateToRestaurantPage(context, vm);
        }
      },
      onTap: () {
        _navigateToRestaurantPage(context, vm);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    restaurant.restaurantName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 24, height: 24, child: vm.overallVeganTag.image),
                Row(
                  children:
                      restaurant.genreTags.map((tagString) {
                        final tag = GenreTag.fromString(tagString);
                        return Row(
                          children: [
                            const VerticalDivider(width: 7, thickness: 1),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: tag.color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag.title,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < vm.averageRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    vm.averagePriceLevel,
                    (index) => SizedBox(
                      width: 14,
                      child: Icon(
                        Icons.attach_money,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              icon: const Icon(Icons.navigation_outlined),
              label: const Text('Navigate'),
              onPressed: () async {
                final googleMapsUrl = Uri.parse(
                  vm.restaurant!.googleMapURL ??
                      'https://www.google.com/maps/search/?api=1&query=${vm.restaurant!.latitude},${vm.restaurant!.longitude}',
                );
                if (await canLaunchUrl(googleMapsUrl)) {
                  await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                } else {
                  // 如果無法啟動 Google Maps，則顯示錯誤訊息
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
