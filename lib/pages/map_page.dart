// lib/pages/map_page.dart

import 'package:flutter/material.dart' hide BottomSheet;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/view_models/all_restaurants_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/map/bottom_sheet.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/widgets/map/search_bar.dart';
import 'package:foodie/widgets/map/category_button.dart';
import 'package:foodie/widgets/map/preference_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  late FilterOptions _filterOptions;
  GoogleMapController? _mapController;
  final String _mapStyle = '''[{"featureType": "poi","stylers": [{"visibility": "off"}]}]''';

  RestaurantDetailViewModel? _selectedRestaurantDetailVM;
  final double _sheetHeight = 200;

  @override
  void initState() {
    super.initState();
    _filterOptions = FilterOptions(
      selectedGenres: GenreTags.values.toSet(),
      selectedVeganTags: {VeganTags.nonVegetarian},
      isOpenNow: false,
      minRating: 0.0,
      priceRange: const RangeValues(0, 300),
    );
  }

  @override
  void dispose() {
    // 非常重要：在頁面銷毀時，也要 dispose ViewModel 以取消監聽
    _selectedRestaurantDetailVM?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Set<Marker> _createMarkers(List<RestaurantItem> restaurants) {
    double colorToHue(Color color) {
      double r = color.red / 255.0;
      double g = color.green / 255.0;
      double b = color.blue / 255.0;
      double maxVal = r > g ? (r > b ? r : b) : (g > b ? g : b);
      double minVal = r < g ? (r < b ? r : b) : (g < b ? g : b);
      double delta = maxVal - minVal;
      double hue = 0.0;
      if (delta == 0) {
        hue = 0;
      } else if (maxVal == r) {
        hue = 60 * (((g - b) / delta) + 0);
      } else if (maxVal == g) {
        hue = 60 * (((b - r) / delta) + 2);
      } else if (maxVal == b) {
        hue = 60 * (((r - g) / delta) + 4);
      }
      if (hue < 0) hue += 360;
      if (hue >= 360) hue %= 360;
      return hue;
    }

    return restaurants
        .where(
          (restaurant) => _filterOptions.selectedGenres.contains(restaurant.genreTag.toGenreTags()),
        ).where(
          (restaurant) => _filterOptions.selectedVeganTags.contains(restaurant.veganTag.toVeganTags()),
        )
        .map((restaurant) {
          return Marker(
            markerId: MarkerId(restaurant.restaurantId),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(colorToHue(restaurant.genreTag.color)),
            onTap: () {
              if (_selectedRestaurantDetailVM?.restaurantId != restaurant.restaurantId) {
                _selectedRestaurantDetailVM?.dispose();

                final newVM = RestaurantDetailViewModel(
                  restaurantId: restaurant.restaurantId,
                  restaurantRepository: context.read<RestaurantRepository>(),
                  reviewRepository: context.read<ReviewRepository>(),
                  userRepository: context.read<UserRepository>(),
                );

                setState(() {
                  _selectedRestaurantDetailVM = newVM;
                });
              }
            },
          );
        })
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final allRestaurantViewModel = context.watch<AllRestaurantViewModel>();
    final restaurants = allRestaurantViewModel.restaurants;
    final restaurantMarkers = _createMarkers(restaurants);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(24.7956, 120.9936),
                zoom: 15,
              ),
              markers: restaurantMarkers,
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController?.setMapStyle(_mapStyle);
              },
              onTap: (LatLng position) {
                FocusScope.of(context).unfocus();
                setState(() {
                  _selectedRestaurantDetailVM?.dispose();
                  _selectedRestaurantDetailVM = null;
                });
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(child: SearchBarWidget(controller: _searchController)),
                    const SizedBox(width: 8),
                    CategoryButton(
                      options: _filterOptions,
                      onUpdate: (newOptions) => setState(() => _filterOptions = newOptions),
                    ),
                    const SizedBox(width: 8),
                    PreferenceButton(
                      options: _filterOptions,
                      onUpdate: (newOptions) => setState(() => _filterOptions = newOptions),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _selectedRestaurantDetailVM != null ? 0 : -_sheetHeight,
            left: 0,
            right: 0,
            height: _sheetHeight,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (_selectedRestaurantDetailVM == null) {
      return const SizedBox.shrink();
    }
    return ChangeNotifierProvider.value(
      value: _selectedRestaurantDetailVM!,
      child: const BottomSheet(),
    );
  }
}
