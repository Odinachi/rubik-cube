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

class _CubeViewState extends State<CubeView> {
  CubeState _cubeState = CubeState();
  
  double _rx = -pi / 6; // Initial rotation X
  double _ry = pi / 4;  // Initial rotation Y
  
  bool _prime = false; // Whether the next move is counter-clockwise

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rx += details.delta.dy * 0.01;
      _ry -= details.delta.dx * 0.01;
    });
  }

  void _performMove(int axis, int layer) {
    setState(() {
      _cubeState.rotateSlice(axis, layer, _prime ? -1 : 1);
    });
  }

  void _resetCube() {
    setState(() {
      _cubeState.cubies.clear();
      _cubeState = CubeState();
      _rx = -pi / 6;
      _ry = pi / 4;
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
      double cx = cubie.x * size + offset.x;
      double cy = cubie.y * size + offset.y;
      double cz = cubie.z * size + offset.z;

      Vector3 center = Vector3(cx, cy, cz);
      Vector3 transformedCenter = Vector3.copy(center);
      globalTransform.perspectiveTransform(transformedCenter);

      Matrix4 faceTransform = Matrix4.identity()
        ..translate(cubie.x * size, cubie.y * size, cubie.z * size)
        ..multiply(localRot);

      faces.add(RenderFace(
        faceTransform,
        color ?? Colors.black87,
        transformedCenter.z,
      ));
    }

    for (var cubie in _cubeState.cubies) {
      addFace(cubie, cubie.backColor, Vector3(0, 0, -half), Matrix4.identity()..translate(0.0, 0.0, -half)..rotateY(pi));
      addFace(cubie, cubie.upColor, Vector3(0, -half, 0), Matrix4.identity()..translate(0.0, -half, 0.0)..rotateX(-pi / 2));
      addFace(cubie, cubie.downColor, Vector3(0, half, 0), Matrix4.identity()..translate(0.0, half, 0.0)..rotateX(pi / 2));
      addFace(cubie, cubie.leftColor, Vector3(-half, 0, 0), Matrix4.identity()..translate(-half, 0.0, 0.0)..rotateY(-pi / 2));
      addFace(cubie, cubie.rightColor, Vector3(half, 0, 0), Matrix4.identity()..translate(half, 0.0, 0.0)..rotateY(pi / 2));
      addFace(cubie, cubie.frontColor, Vector3(0, 0, half), Matrix4.identity()..translate(0.0, 0.0, half));
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Prime (\')', style: TextStyle(color: Colors.white, fontSize: 16)),
              Switch(
                value: _prime,
                onChanged: (val) => setState(() => _prime = val),
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
