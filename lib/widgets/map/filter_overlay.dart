// lib/widgets/map/filter_overlay.dart
import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/filter_options.dart';

class FilterOverlay extends StatefulWidget {
  final RenderBox buttonRenderBox;
  final VoidCallback onClose;
  final FilterOptions initialOptions;
  final Function(FilterOptions) onUpdate; // 用於即時更新狀態

  const FilterOverlay({
    Key? key,
    required this.buttonRenderBox,
    required this.onClose,
    required this.initialOptions,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  late FilterOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    // 複製一份狀態，避免直接修改父層的 state
    _currentOptions = widget.initialOptions.copyWith();
  }

  // === 動態 UI 生成器 ===
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // 通用的 Checkbox 列表產生器
  Widget _buildTagSelection<T extends Enum>(
      String title,
      Map<T, dynamic> allTags, // 例如 veganTags map
      Set<T> selectedTags,     // 目前選中的集合
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: allTags.keys.map((tag) {
            final tagInfo = allTags[tag]!;
            final isSelected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tagInfo.title),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedTags.add(tag);
                  } else {
                    selectedTags.remove(tag);
                  }
                  // 通知 MapPage 更新狀態
                  widget.onUpdate(_currentOptions);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final buttonPosition = widget.buttonRenderBox.localToGlobal(Offset.zero);
    final buttonSize = widget.buttonRenderBox.size;

    // ... (Positioned 和 Material 的程式碼與之前類似)
    // 我們只專注於 filterPanel 的 child
    Widget filterPanel = Material(
        // ...
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 使用新的動態產生器來建立 UI
              _buildTagSelection<GenreTags>(
                '餐廳類型',
                genreTags, // 從 genre_tag.dart 匯入
                _currentOptions.selectedGenres,
              ),

              _buildTagSelection<VeganTags>(
                '素食友善',
                veganTags, // 從 vegan_tag.dart 匯入
                _currentOptions.selectedVeganTags,
              ),

              // ... 其他篩選器，例如價格滑桿等 ...
            ],
          ),
        ),
    );
    // ... Stack and positioning code
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
        ),
        Positioned(
          top: buttonPosition.dy + buttonSize.height + 8,
          left: (MediaQuery.of(context).size.width * 0.05),
          right: (MediaQuery.of(context).size.width * 0.05),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: filterPanel,
          ),
        ),
      ],
    );
  }
}
