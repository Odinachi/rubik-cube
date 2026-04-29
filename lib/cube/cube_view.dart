import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'cube_state.dart';
import 'cubie_view.dart';
import 'cubie.dart';

class CubeView extends StatefulWidget {
  const CubeView({Key? key}) : super(key: key);

  @override
  _CubeViewState createState() => _CubeViewState();
}

class RenderFace {
  final Matrix4 transform;
  final Color color;
  final double zDepth;

  RenderFace(this.transform, this.color, this.zDepth);
}

class CubeMove {
  final int axis;
  final int layer;
  final int dir;
  CubeMove(this.axis, this.layer, this.dir);
  
  CubeMove get reverse => CubeMove(axis, layer, -dir);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CubeMove &&
          runtimeType == other.runtimeType &&
          axis == other.axis &&
          layer == other.layer &&
          dir == other.dir;

  @override
  int get hashCode => axis.hashCode ^ layer.hashCode ^ dir.hashCode;
  
  String get name {
    String base = '';
    if (axis == 1 && layer == -1) base = 'U';
    else if (axis == 1 && layer == 1) base = 'D';
    else if (axis == 0 && layer == -1) base = 'L';
    else if (axis == 0 && layer == 1) base = 'R';
    else if (axis == 2 && layer == 1) base = 'F';
    else if (axis == 2 && layer == -1) base = 'B';
    
    if (dir == -1) return "$base'";
    return base;
  }
}

class _CubeViewState extends State<CubeView> with SingleTickerProviderStateMixin {
  CubeState _cubeState = CubeState();
  
  double _rx = -pi / 6; // Initial rotation X
  double _ry = pi / 4;  // Initial rotation Y
  
  bool _prime = false; // Whether the next move is counter-clockwise

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;
  int _animAxis = 0;
  int _animLayer = 0;
  int _animDir = 0;
  
  List<CubeMove> _moveHistory = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rx += details.delta.dy * 0.01;
      _ry -= details.delta.dx * 0.01;
    });
  }

  void _performMove(int axis, int layer) {
    if (_isAnimating) return;
    int dir = _prime ? -1 : 1;
    CubeMove move = CubeMove(axis, layer, dir);

    setState(() {
      _isAnimating = true;
      _animAxis = axis;
      _animLayer = layer;
      _animDir = dir;
      
      if (_moveHistory.isNotEmpty && _moveHistory.last.reverse == move) {
        _moveHistory.removeLast();
      } else {
        _moveHistory.add(move);
      }
    });
    
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _cubeState.rotateSlice(_animAxis, _animLayer, _animDir);
        });
      }
      _controller.reset();
    });
  }

  void _scrambleCube() {
    if (_isAnimating) return;
    final random = Random();
    setState(() {
      _moveHistory.clear();
      for (int i = 0; i < 20; i++) {
        int axis = random.nextInt(3);
        int layer = random.nextBool() ? 1 : -1;
        int dir = random.nextBool() ? 1 : -1;
        _cubeState.rotateSlice(axis, layer, dir);
        _moveHistory.add(CubeMove(axis, layer, dir));
      }
    });
  }

  void _resetCube() {
    setState(() {
      _cubeState.cubies.clear();
      _cubeState = CubeState();
      _rx = -pi / 6;
      _ry = pi / 4;
      _moveHistory.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    // Create the global rotation matrix to calculate Z-depth
    final Matrix4 globalTransform = Matrix4.identity()
      ..rotateX(_rx)
      ..rotateY(_ry);

    List<RenderFace> faces = [];
    double size = 60.0;
    double half = size / 2;

    void addFace(Cubie cubie, Color? color, Vector3 offset, Matrix4 localRot) {
      bool isAnimated = false;
      if (_isAnimating) {
        if (_animAxis == 0 && cubie.x.round() == _animLayer) isAnimated = true;
        if (_animAxis == 1 && cubie.y.round() == _animLayer) isAnimated = true;
        if (_animAxis == 2 && cubie.z.round() == _animLayer) isAnimated = true;
      }

      Matrix4 animMatrix = Matrix4.identity();
      if (isAnimated) {
        double angle = _animation.value * _animDir * (pi / 2);
        if (_animAxis == 0) animMatrix.rotateX(angle);
        else if (_animAxis == 1) animMatrix.rotateY(angle);
        else if (_animAxis == 2) animMatrix.rotateZ(angle);
      }

      double cx = cubie.x * size + offset.x;
      double cy = cubie.y * size + offset.y;
      double cz = cubie.z * size + offset.z;

      Vector3 center = Vector3(cx, cy, cz);
      animMatrix.transform3(center);

      Vector3 transformedCenter = Vector3.copy(center);
      globalTransform.perspectiveTransform(transformedCenter);

      Matrix4 faceTransform = animMatrix.clone()
        ..translate(cubie.x * size, cubie.y * size, cubie.z * size)
        ..multiply(localRot);

      faces.add(RenderFace(
        faceTransform,
        color ?? Colors.black87,
        transformedCenter.z,
      ));
    }

    for (var cubie in _cubeState.cubies) {
      addFace(cubie, cubie.upColor, Vector3(0, -half, 0), Matrix4.identity()..translate(0.0, -half, 0.0)..rotateX(-pi / 2));
      addFace(cubie, cubie.downColor, Vector3(0, half, 0), Matrix4.identity()..translate(0.0, half, 0.0)..rotateX(pi / 2));
      addFace(cubie, cubie.leftColor, Vector3(-half, 0, 0), Matrix4.identity()..translate(-half, 0.0, 0.0)..rotateY(-pi / 2));
      addFace(cubie, cubie.rightColor, Vector3(half, 0, 0), Matrix4.identity()..translate(half, 0.0, 0.0)..rotateY(pi / 2));
      addFace(cubie, cubie.backColor, Vector3(0, 0, half), Matrix4.identity()..translate(0.0, 0.0, half)..rotateY(pi));
      addFace(cubie, cubie.frontColor, Vector3(0, 0, -half), Matrix4.identity()..translate(0.0, 0.0, -half));
    }

    // Sort faces from back to front
    // In Flutter, +Z goes INTO the screen, so larger Z is further away.
    // We want to draw further objects first (bottom of stack), so we sort descending.
    faces.sort((a, b) => b.zDepth.compareTo(a.zDepth));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Rubik\'s Cube'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Hint',
            onPressed: () {
              if (_moveHistory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('The cube is already solved!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hint: Play ${_moveHistory.last.reverse.name}')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCube,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Container(
                color: Colors.transparent, // Catch gestures
                child: Center(
                  child: Transform(
                    transform: globalTransform,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: faces.map((face) {
                        return Transform(
                          transform: face.transform,
                          alignment: Alignment.center,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: face.color,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }


  
  Widget _buildControls() {
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
                  const Text('Prime (\')', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _prime,
                    onChanged: (val) => setState(() => _prime = val),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _scrambleCube,
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
