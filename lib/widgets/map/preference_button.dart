import 'package:flutter/material.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:foodie/widgets/map/preference_overlay.dart';

class PreferenceButton extends StatefulWidget {
  final FilterOptions options;
  final Function(FilterOptions) onUpdate;

  const PreferenceButton({Key? key, required this.options, required this.onUpdate})
    : super(key: key);

  @override
  State<PreferenceButton> createState() => _PreferenceButtonState();
}

class _PreferenceButtonState extends State<PreferenceButton> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  void _toggleOverlay() {
    setState(() {
      if (!_isOverlayVisible) {
        _isOverlayVisible = true;
        final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
        _overlayEntry = OverlayEntry(
          builder:
              (context) => PreferenceOverlay(
                buttonRenderBox: renderBox,
                onClose: _toggleOverlay,
                initialOptions: widget.options, // 傳遞從 MapPage 來的狀態
                onUpdate: widget.onUpdate, // 傳遞從 MapPage 來的更新函式
              ),
        );
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _isOverlayVisible = false;
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    // 確保 Widget 被銷毀時移除 overlay
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根據 overlay 是否可見來決定按鈕樣式
    final Color borderColor =
        _isOverlayVisible ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurfaceVariant;
    final double borderWidth = _isOverlayVisible ? 2.0 : 1.0;
    final Color iconColor =
        _isOverlayVisible ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      key: _buttonKey,
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _toggleOverlay,
        child: Icon(Icons.tune, color: iconColor),
      ),
    );
  }
}
