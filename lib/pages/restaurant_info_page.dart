import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/firebase_image.dart';
import 'package:foodie/widgets/restaurant/restaurant_info_card.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Restaurant Info Card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RestaurantInfoCard(),
          ),
          const SizedBox(height: 16),

          // 2. Image Carousel
          SizedBox(
            height: 120,
            child: imageURLs.isNotEmpty
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: imageURLs.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => Card(
                      clipBehavior: Clip.antiAlias,
                      child: FirebaseImage(gsUri: imageURLs[index], width: 120),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // 3. Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

          // 4. Information Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Information', style: Theme.of(context).textTheme.titleLarge),
          ),
          ExpansionTile(
            leading: const Icon(Icons.access_time_outlined),
            title: Text(restaurant.businessHour['weekday'] ?? 'Business Hours'),
            children: restaurant.businessHour.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(entry.value),
                dense: true,
              );
            }).toList(),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(restaurant.phoneNumber),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(restaurant.address),
          ),
        ],
      ),
    );
  }
}
