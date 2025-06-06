import 'package:flutter/material.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/filter_options.dart';

class PreferenceOverlay extends StatefulWidget {
  final RenderBox buttonRenderBox;
  final VoidCallback onClose;
  final FilterOptions initialOptions;
  final Function(FilterOptions) onUpdate;

  const PreferenceOverlay({
    Key? key,
    required this.buttonRenderBox,
    required this.onClose,
    required this.initialOptions,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<PreferenceOverlay> createState() => _PreferenceOverlayState();
}

class _PreferenceOverlayState extends State<PreferenceOverlay> {
  late FilterOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.initialOptions.copyWith();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
    );
  }
  
  // 素別/清真認證的 UI 生成器
  Widget _buildVeganCheckbox(VeganTags veganTag) {
    final tagInfo = veganTags[veganTag]!;
    final isSelected = _currentOptions.selectedVeganTags.contains(veganTag);
    return CheckboxListTile(
        title: Text(tagInfo.title),
        secondary: SizedBox(height: 24, child: tagInfo.image), // 顯示圖示
        value: isSelected,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _currentOptions.selectedVeganTags.add(veganTag);
            } else {
              _currentOptions.selectedVeganTags.remove(veganTag);
            }
            widget.onUpdate(_currentOptions);
          });
        });
  }


  @override
  Widget build(BuildContext context) {
    final buttonPosition = widget.buttonRenderBox.localToGlobal(Offset.zero);
    final buttonSize = widget.buttonRenderBox.size;

    Widget filterPanel = Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 營業時間
              _buildSectionHeader('營業時間'),
              ToggleButtons(
                isSelected: [_currentOptions.isOpenNow, !_currentOptions.isOpenNow],
                onPressed: (index) {
                  setState(() {
                    _currentOptions.isOpenNow = (index == 0);
                    widget.onUpdate(_currentOptions);
                  });
                },
                borderRadius: BorderRadius.circular(20),
                children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('營業中')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('不設限'))],
              ),

              // 價格
              _buildSectionHeader('價格'),
              RangeSlider(
                values: _currentOptions.priceRange,
                min: 0, max: 500, divisions: 5,
                labels: RangeLabels('\$${_currentOptions.priceRange.start.round()}', '\$${_currentOptions.priceRange.end.round()}'),
                onChanged: (values) {
                  setState(() { _currentOptions.priceRange = values; });
                },
                onChangeEnd: (values) { widget.onUpdate(_currentOptions); }, // 拖動結束後再更新
              ),

              // 評價
              _buildSectionHeader('評價'),
              Slider(
                value: _currentOptions.minRating,
                min: 0, max: 5, divisions: 10,
                label: _currentOptions.minRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() { _currentOptions.minRating = value; });
                },
                onChangeEnd: (value) { widget.onUpdate(_currentOptions); },
              ),
              
              // 素別
              _buildSectionHeader('素別'),
              // 使用 ListView.builder 動態生成素食選項
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: VeganTags.values.length,
                itemBuilder: (context, index) {
                   final veganTag = VeganTags.values[index];
                   return _buildVeganCheckbox(veganTag);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            // CHANGED: 移除黑色背景，改為透明
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          top: buttonPosition.dy + buttonSize.height + 8,
          left: (MediaQuery.of(context).size.width * 0.05),
          right: (MediaQuery.of(context).size.width * 0.05),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: filterPanel,
          ),
        ),
      ],
    );
  }
}
