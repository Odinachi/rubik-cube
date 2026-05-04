import 'package:flutter/material.dart';

class CubeControls extends StatefulWidget {
  final VoidCallback onScramble;
  final void Function(int axis, int layer, int dir) onMove;

  const CubeControls({
    super.key,
    required this.onScramble,
    required this.onMove,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Prime (\')',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: _prime,
                    onChanged: (val) => setState(() => _prime = val),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onScramble,
                icon: const Icon(Icons.shuffle),
                label: const Text('Scramble'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn('U', () => _performMove(1, -1)),
              _btn('D', () => _performMove(1, 1)),
              _btn('L', () => _performMove(0, -1)),
              _btn('R', () => _performMove(0, 1)),
              _btn('F', () => _performMove(2, 1)),
              _btn('B', () => _performMove(2, -1)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label + (_prime ? "'" : ""),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
