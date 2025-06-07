import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:provider/provider.dart';

class RestaurantInfoPage extends StatelessWidget {
  const RestaurantInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final restaurant = vm.restaurant;
    final imageURLs = vm.displayImageUrls;

    if (restaurant == null) {
      return const Center(child: Text('Restaurant data not found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: imageURLs.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: imageURLs.length,
                    itemBuilder: (context, index) => Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        imageURLs[index],
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      ),
                    ),
                  )
                : const Center(child: Text("No images yet")),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(restaurant.summary, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Information', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_outlined),
            title: Text(restaurant.businessHour['weekday'] ?? 'No business hours available'),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(restaurant.phoneNumber),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(restaurant.address),
          ),
        ],
      ),
    );
  }
}
