// lib/pages/map_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/models/filter_options.dart'; // NEW
import 'package:foodie/enums/genre_tag.dart';      // NEW
import 'package:foodie/enums/vegan_tag.dart';      // NEW
import 'package:foodie/widgets/map/google_map.dart';
import 'package:foodie/widgets/map/search_bar.dart';
import 'package:foodie/widgets/map/category_button.dart';
import 'package:foodie/widgets/map/preference_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();

  // === THE SINGLE SOURCE OF TRUTH ===
  late FilterOptions _filterOptions;

  @override
  void initState() {
    super.initState();
    // 初始化所有篩選條件
    _filterOptions = FilterOptions(
      // 預設選中 'FastFood' 和 'Hotpot'
      selectedGenres: {GenreTags.fastFood, GenreTags.hotpot}, 
      // 預設不選中任何素食標籤
      selectedVeganTags: {},
    );
  }

  // 狀態更新函式
  void _updateFilters(FilterOptions newOptions) {
    setState(() {
      _filterOptions = newOptions;
      // 在這裡，您可以根據新的 _filterOptions 重新篩選地圖上的 markers
      print("Filters updated! New genres: ${_filterOptions.selectedGenres}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMapWidget(
              // TODO:
              initialPosition: CameraPosition(
                target: LatLng(24.7956, 120.9936), // 竹科附近
                zoom: 15,
              ),
              markers: {}, // 這裡之後接 marker
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(child: SearchBarWidget(controller: _searchController)),
                    const SizedBox(width: 8),

                    // 將狀態和更新函式傳遞給按鈕
                    PreferenceButton(
                      options: _filterOptions,
                      onUpdate: _updateFilters,
                    ),
                    const SizedBox(width: 8),
                    CategoryButton(
                      options: _filterOptions,
                      onUpdate: _updateFilters,
                    ),
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
