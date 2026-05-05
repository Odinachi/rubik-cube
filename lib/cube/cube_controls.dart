import 'dart:ui';
import 'package:flutter/material.dart';

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
                  'Prime (\')',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _prime,
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (val) => setState(() => _prime = val),
                ),
              ],
            ),
            if (widget.isVertical) const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onScramble,
              icon: const Icon(Icons.shuffle),
              label: const Text('Scramble'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.isVertical ? 32 : 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _btn('U', () => _performMove(1, -1)),
            _btn('D', () => _performMove(1, 1)),
            _btn('L', () => _performMove(0, -1)),
            _btn('R', () => _performMove(0, 1)),
            _btn('F', () => _performMove(2, 1)),
            _btn('B', () => _performMove(2, -1)),
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
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: widget.isVertical
                ? const BorderRadius.horizontal(left: Radius.circular(32))
                : const BorderRadius.vertical(top: Radius.circular(32)),
          ),
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
        hoverColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.deepPurpleAccent.withOpacity(0.3),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label + (_prime ? "'" : ""),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
