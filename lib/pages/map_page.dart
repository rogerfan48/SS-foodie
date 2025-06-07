import 'package:flutter/material.dart' hide BottomSheet;
import 'package:foodie/view_models/info_page_vm.dart';
import 'package:foodie/widgets/map/bottom_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/widgets/map/google_map.dart';
import 'package:foodie/widgets/map/search_bar.dart';
import 'package:foodie/widgets/map/category_button.dart';
import 'package:foodie/widgets/map/preference_button.dart';
import 'package:foodie/widgets/map/bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  late FilterOptions _filterOptions;
  late GoogleMapController _mapController;
  final String _mapStyle = '''[
    {
      "featureType": "poi",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    }
  ]''';
  PersistentBottomSheetController? _controller;
  double _sheetHeight = 200;

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

  void _updateFilters(FilterOptions newOptions) {
    setState(() {
      _filterOptions = newOptions;
      // 在這裡，您可以根據新的 _filterOptions 重新篩選地圖上的 markers
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 如果你想要 full screen 效果時會用到
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return BottomSheet(
          info: RestaurantInfo(
            restaurantName: "中式餐廳1",
            summary: "summary",
            address: "address",
            phoneNumber: "phoneNumber",
            businessHour: {},
            genreTags: [
              genreTags[GenreTags.chinese]!,
              genreTags[GenreTags.barbecue]!,
              genreTags[GenreTags.hotpot]!,
            ],
            veganTag: veganTags[VeganTags.lacto]!,
            priceLevel: 1,
            rating: 1,
            imageURLs: ["imageURLs"],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> restaurantMarkers = {
      Marker(
        markerId: MarkerId('library'),
        position: LatLng(24.795188206929602, 120.9947881482545),
        onTap: () {
          _showBottomSheet(context);
        },
      ),
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(24.7956, 120.9936), zoom: 15),
              markers: restaurantMarkers,
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController.setMapStyle(_mapStyle);
              },
              onTap: (LatLng position) {
                FocusScope.of(context).unfocus();
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
                    CategoryButton(options: _filterOptions, onUpdate: _updateFilters),
                    const SizedBox(width: 8),
                    PreferenceButton(options: _filterOptions, onUpdate: _updateFilters),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
