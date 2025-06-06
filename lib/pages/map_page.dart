import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/widgets/google_map_widget.dart';
import 'package:foodie/widgets/map_search_bar.dart';
import 'package:foodie/widgets/bottom_nav_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _tabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMapWidget( // TODO:
              initialPosition: CameraPosition(
                target: LatLng(24.7956, 120.9936), // 竹科附近
                zoom: 15,
              ),
              markers: {}, // 這裡之後接 marker
            ),
            // 搜尋欄 + 按鈕
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SearchBarWidget(
                controller: _searchController,
                onFilterPressed: () {}, // 實作過濾
                onListPressed: () {},   // 實作清單
              ),
            ),
          ],
        ),
      ),
    );
  }
}
