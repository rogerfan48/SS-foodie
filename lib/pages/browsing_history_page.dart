import 'package:flutter/material.dart';
import 'package:foodie/view_models/viewed_restaurants_vm.dart';
import 'package:foodie/widgets/account/history_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BrowsingHistoryPage extends StatelessWidget {
  const BrowsingHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ViewedRestaurantsViewModel?>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Browsing History'),
      ),
      body:
          (viewModel == null || viewModel.viewedRestaurants.isEmpty)
              ? const Center(child: Text('You have no browsing history yet.'))
              : ListView.builder(
                itemCount: viewModel.viewedRestaurants.length,
                itemBuilder: (context, index) {
                  final historyItem = viewModel.viewedRestaurants[index];
                  return HistoryListTile(
                    restaurantName: historyItem.restaurantName ?? 'N/A',
                    genre: historyItem.genreTag?.title ?? 'N/A',
                    date: historyItem.viewDate?.toIso8601String().split('T').first ?? 'N/A',
                    onDelete: () {
                      // viewModel.deleteViewedRestaurant(historyItem.restaurantId);
                    },
                  );
                },
              ),
    );
  }
}
