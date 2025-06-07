import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/view_models/info_page_vm.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class BottomSheet extends StatefulWidget {
  final RestaurantInfo info;

  const BottomSheet({Key? key, required this.info}) : super(key: key);

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  double _sheetHeight = 200;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _sheetHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 32,
              right: 32,
              child: Column(
                children: [
                  // Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.info.restaurantName),
                      IconButton(
                        icon: const Icon(Icons.expand_less),
                        onPressed: () {
                          setState(() {
                            context.go('/map/restaurant');
                          });
                        },
                      ),
                    ],
                  ),
                  // Tags
                  Row(
                    children: [
                      SizedBox(width: 24, height: 24, child: widget.info.veganTag.image),
                      Row(
                        children:
                            widget.info.genreTags.map((tag) {
                              return Row(
                                children: [
                                  const VerticalDivider(width: 7, thickness: 1),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
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
                  // Rate
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          widget.info.rating,
                          (index) => const Icon(Icons.star, color: Colors.amber),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5 - widget.info.rating,
                          (index) => const Icon(Icons.star, color: Colors.grey),
                        ),
                      ),
                      const VerticalDivider(width: 14, thickness: 1),
                      Row(
                        children: List.generate(
                          widget.info.priceLevel,
                          (index) => const Icon(Icons.attach_money, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  // Navigation
                  ElevatedButton(
                    onPressed: () async {
                      final googleMapsUrl = Uri.parse(
                        'https://maps.app.goo.gl/ZgLefs3YvWr6a3tWA',  // vm 需要新增
                      );
                      if (await canLaunchUrl(googleMapsUrl)) {
                        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                      } else {
                        print('無法開啟 Google 地圖');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.navigation),
                        Text(
                          'Navigation',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
