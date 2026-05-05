import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/app_styles.dart';

class CubeControls extends StatefulWidget {
  final VoidCallback onScramble;
  final void Function(int axis, int layer, int dir) onMove;
  final bool isVertical;

  const CubeControls({
    super.key,
    required this.onScramble,
    required this.onMove,
    this.isVertical = false,
  });

  @override
  State<CubeControls> createState() => _CubeControlsState();
}

class _CubeControlsState extends State<CubeControls> {
  bool _prime = false;

  void _performMove(int axis, int layer) {
    int dir = _prime ? -1 : 1;
    widget.onMove(axis, layer, dir);
  }

  @override
  Widget build(BuildContext context) {
    Widget controls = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isVertical) const SizedBox(height: 32),
        Flex(
          direction: widget.isVertical ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.primeToggle,
                  style: AppStyles.primeToggleStyle,
                ),
                Switch(
                  value: _prime,
                  activeColor: AppColors.seedColor,
                  onChanged: (val) => setState(() => _prime = val),
                ),
              ],
            ),
            if (widget.isVertical) const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onScramble,
              icon: const Icon(Icons.shuffle),
              label: const Text(AppStrings.scrambleButton),
              style: AppStyles.scrambleButtonStyle,
            ),
          ],
        ),
        SizedBox(height: widget.isVertical ? 32 : 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _btn(AppStrings.moveU, () => _performMove(1, -1)),
            _btn(AppStrings.moveD, () => _performMove(1, 1)),
            _btn(AppStrings.moveL, () => _performMove(0, -1)),
            _btn(AppStrings.moveR, () => _performMove(0, 1)),
            _btn(AppStrings.moveF, () => _performMove(2, 1)),
            _btn(AppStrings.moveB, () => _performMove(2, -1)),
          ],
        ),
        if (widget.isVertical) const SizedBox(height: 32),
      ],
    );

    return ClipRRect(
      borderRadius: widget.isVertical
          ? const BorderRadius.horizontal(left: Radius.circular(32))
          : const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: widget.isVertical ? double.infinity : null,
          height: widget.isVertical ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: widget.isVertical ? 48 : 24,
          ),
          decoration: widget.isVertical
              ? AppStyles.glassContainerVertical
              : AppStyles.glassContainerHorizontal,
          child: widget.isVertical 
              ? SingleChildScrollView(child: controls) 
              : controls,
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppColors.buttonHover,
        splashColor: AppColors.buttonSplash,
        child: Ink(
          width: 64,
          height: 64,
          decoration: AppStyles.moveButtonDecoration(false),
          child: Center(
            child: Text(
              label + (_prime ? "'" : ""),
              style: AppStyles.moveButtonTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
