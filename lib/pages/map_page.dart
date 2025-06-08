import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart' hide BottomSheet;
import 'package:foodie/services/map_position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/services/storage_service.dart';
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

  final Map<Color, BitmapDescriptor> _markerIconCache = {};

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
    final String? id = context.read<MapPositionService>().id;
    if (id != null) {
      _selectedRestaurantDetailVM = RestaurantDetailViewModel(
        restaurantId: id,
        restaurantRepository: context.read<RestaurantRepository>(),
        reviewRepository: context.read<ReviewRepository>(),
        userRepository: context.read<UserRepository>(),
        storageService: context.read<StorageService>(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MapPositionService>().updateId(null);
      });
    }
  }

  @override
  void dispose() {
    // 非常重要：在頁面銷毀時，也要 dispose ViewModel 以取消監聽
    _selectedRestaurantDetailVM?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<BitmapDescriptor> _createCustomMarker(Color color) async {
    if (_markerIconCache.containsKey(color)) {
      return _markerIconCache[color]!;
    }

    // 1. ✅ 定義一個包含兩個顏色佔位符的 SVG 模板
    const String svgTemplate = '''
    <svg width="100" height="120" viewBox="-5 -5 110 125" xmlns="http://www.w3.org/2000/svg">
      <path 
        fill="#FILL_COLOR#" 
        stroke="#FILL_COLOR_DARK#" 
        stroke-width="4" 
        d="M50 0 C22.38 0 0 22.38 0 50 C0 85 50 120 50 120 S100 85 100 50 C100 22.38 77.62 0 50 0 Z"
      />
      <circle fill="#FILL_COLOR_DARK#" cx="50" cy="50" r="25"/>
    </svg>
    ''';


    // 2. 計算主顏色的深色版本
    final HSLColor hslColor = HSLColor.fromColor(color);
    final HSLColor darkerHslColor = hslColor.withLightness(
      (hslColor.lightness - 0.15).clamp(0.0, 1.0),
    );
    final Color darkerColor = darkerHslColor.toColor();

    // 3. 將 Color 物件轉換為 16 進位顏色字串
    final String mainColorString = '#${color.value.toRadixString(16).substring(2)}';
    final String darkColorString = '#${darkerColor.value.toRadixString(16).substring(2)}';

    // 4. ✅ 分別替換兩個顏色佔位符
    final String finalSvgString = svgTemplate
        .replaceAll('#FILL_COLOR#', mainColorString)
        .replaceAll('#FILL_COLOR_DARK#', darkColorString);

    // 5. 使用 flutter_svg 將 SVG 字串渲染成圖片
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(finalSvgString), null);
    final ui.Image image = await pictureInfo.picture.toImage(120, 150); // 提高解析度以獲得更清晰的圖標
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    final bitmapDescriptor = BitmapDescriptor.fromBytes(uint8List);

    _markerIconCache[color] = bitmapDescriptor;
    return bitmapDescriptor;
  }

  Future<Set<Marker>> _createMarkers(List<RestaurantItem> restaurants) async {
    final List<Future<Marker>> markerFutures =
        restaurants
            .where(
              (restaurant) =>
                  _filterOptions.selectedGenres.contains(restaurant.genreTag.toGenreTags()),
            )
            .where((restaurant) => (restaurant.veganTag.level <= _filterOptions.maxVeganLevel))
            .map((restaurant) async {
              return Marker(
                markerId: MarkerId(restaurant.restaurantId),
                position: LatLng(restaurant.latitude, restaurant.longitude),
                // 使用我們自訂的方法來生成圖標
                icon: await _createCustomMarker(restaurant.genreTag.color),
                onTap: () {
                  if (_selectedRestaurantDetailVM?.restaurantId != restaurant.restaurantId) {
                    _selectedRestaurantDetailVM?.dispose();
                    final newVM = RestaurantDetailViewModel(
                      restaurantId: restaurant.restaurantId,
                      restaurantRepository: context.read<RestaurantRepository>(),
                      reviewRepository: context.read<ReviewRepository>(),
                      userRepository: context.read<UserRepository>(),
                      storageService: context.read<StorageService>(),
                    );
                    setState(() {
                      _selectedRestaurantDetailVM = newVM;
                    });
                  }
                },
              );
            })
            .toList();

    return Future.wait(markerFutures).then((markers) => markers.toSet());
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = context.read<MapPositionService>().position;
    final allRestaurantViewModel = context.watch<AllRestaurantViewModel>();
    final restaurants = allRestaurantViewModel.restaurants;
    final restaurantMarkers = _createMarkers(restaurants);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // ✅ 使用 FutureBuilder 來等待 Markers 生成完畢
            child: FutureBuilder<Set<Marker>>(
              future: _createMarkers(restaurants),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // 在 Markers 生成期間，可以顯示一個 Loading 或空的 Map
                  return const Center(child: CircularProgressIndicator());
                }
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: context.read<MapPositionService>().position,
                    zoom: 15,
                  ),
                  markers: snapshot.data ?? {},
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
                  onCameraMove: (position) {
                    context.read<MapPositionService>().updatePosition(position.target);
                  },
                );
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
