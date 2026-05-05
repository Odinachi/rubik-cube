import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:confetti/confetti.dart';
import 'cube_state.dart';
import 'cubie.dart';
import 'cube_move.dart';
import 'cube_controls.dart';

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

class _CubeViewState extends State<CubeView>
    with SingleTickerProviderStateMixin {
  CubeState _cubeState = CubeState();

  double _rx = -pi / 6; // Initial rotation X
  double _ry = pi / 4; // Initial rotation Y

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;
  int _animAxis = 0;
  int _animLayer = 0;
  int _animDir = 0;

  List<CubeMove> _moveHistory = [];
  bool _isScrambling = false;
  bool _isAutoSolving = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rx += details.delta.dy * 0.01;
      _ry -= details.delta.dx * 0.01;
    });
  }

  Future<void> _animateMove(
    int axis,
    int layer,
    int dir, {
    int durationMs = 300,
  }) async {
    if (!mounted) return;

    setState(() {
      _isAnimating = true;
      _animAxis = axis;
      _animLayer = layer;
      _animDir = dir;
    });

    _controller.duration = Duration(milliseconds: durationMs);
    await _controller.forward(from: 0.0);

    if (mounted) {
      setState(() {
        _isAnimating = false;
        _cubeState.rotateSlice(_animAxis, _animLayer, _animDir);
      });
      _controller.reset();

      if (!_isScrambling && _cubeState.isSolved()) {
        _confettiController.play();
        _moveHistory.clear();
      }
    }
  }

  void _performMove(int axis, int layer, int dir) {
    if (_isAnimating || _isScrambling || _isAutoSolving) return;
    CubeMove move = CubeMove(axis, layer, dir);

    setState(() {
      if (_moveHistory.isNotEmpty && _moveHistory.last.reverse == move) {
        _moveHistory.removeLast();
      } else {
        _moveHistory.add(move);
      }
    });

    _animateMove(axis, layer, dir);
  }

  Future<void> _autoSolveCube() async {
    if (_isAnimating || _isScrambling || _isAutoSolving) return;
    
    setState(() {
      _isAutoSolving = true;
    });

    while (_moveHistory.isNotEmpty && mounted && _isAutoSolving) {
      CubeMove reverseMove = _moveHistory.last.reverse;
      
      setState(() {
        _moveHistory.removeLast();
      });
      
      await _animateMove(reverseMove.axis, reverseMove.layer, reverseMove.dir, durationMs: 150);
    }
    
    if (mounted) {
      setState(() {
        _isAutoSolving = false;
      });
    }
  }

  Future<void> _scrambleCube() async {
    if (_isAnimating || _isScrambling || _isAutoSolving) return;

    setState(() {
      _isScrambling = true;
      _moveHistory.clear();
    });

    final random = Random();
    for (int i = 0; i < 20; i++) {
      if (!mounted) break;
      int axis = random.nextInt(3);
      int layer = random.nextBool() ? 1 : -1;
      int dir = random.nextBool() ? 1 : -1;

      setState(() {
        _moveHistory.add(CubeMove(axis, layer, dir));
      });

      await _animateMove(axis, layer, dir, durationMs: 150);
    }

    if (mounted) {
      setState(() {
        _isScrambling = false;
      });
    }
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
    final Matrix4 globalTransform =
        Matrix4.identity()
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
        if (_animAxis == 0)
          animMatrix.rotateX(angle);
        else if (_animAxis == 1)
          animMatrix.rotateY(angle);
        else if (_animAxis == 2)
          animMatrix.rotateZ(angle);
      }

      double cx = cubie.x * size + offset.x;
      double cy = cubie.y * size + offset.y;
      double cz = cubie.z * size + offset.z;

      Vector3 center = Vector3(cx, cy, cz);
      animMatrix.transform3(center);

      Vector3 transformedCenter = Vector3.copy(center);
      globalTransform.perspectiveTransform(transformedCenter);

      Matrix4 faceTransform =
          animMatrix.clone()
            ..translate(cubie.x * size, cubie.y * size, cubie.z * size)
            ..multiply(localRot);

      faces.add(
        RenderFace(faceTransform, color ?? Colors.black87, transformedCenter.z),
      );
    }

    for (var cubie in _cubeState.cubies) {
      addFace(
        cubie,
        cubie.upColor,
        Vector3(0, -half, 0),
        Matrix4.identity()
          ..translate(0.0, -half, 0.0)
          ..rotateX(-pi / 2),
      );
      addFace(
        cubie,
        cubie.downColor,
        Vector3(0, half, 0),
        Matrix4.identity()
          ..translate(0.0, half, 0.0)
          ..rotateX(pi / 2),
      );
      addFace(
        cubie,
        cubie.leftColor,
        Vector3(-half, 0, 0),
        Matrix4.identity()
          ..translate(-half, 0.0, 0.0)
          ..rotateY(-pi / 2),
      );
      addFace(
        cubie,
        cubie.rightColor,
        Vector3(half, 0, 0),
        Matrix4.identity()
          ..translate(half, 0.0, 0.0)
          ..rotateY(pi / 2),
      );
      addFace(
        cubie,
        cubie.backColor,
        Vector3(0, 0, half),
        Matrix4.identity()
          ..translate(0.0, 0.0, half)
          ..rotateY(pi),
      );
      addFace(
        cubie,
        cubie.frontColor,
        Vector3(0, 0, -half),
        Matrix4.identity()..translate(0.0, 0.0, -half),
      );
    }

    // Sort faces from back to front
    // In Flutter, +Z goes INTO the screen, so larger Z is further away.
    // We want to draw further objects first (bottom of stack), so we sort descending.
    faces.sort((a, b) => b.zDepth.compareTo(a.zDepth));

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                  SnackBar(
                    content: Text(
                      'Hint: Play ${_moveHistory.last.reverse.name}',
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Auto Solve',
            onPressed: () {
              if (_moveHistory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('The cube is already solved!')),
                );
              } else {
                _autoSolveCube();
              }
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCube),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 800;

            Widget cubeArea = GestureDetector(
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
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );

            Widget controlsArea = CubeControls(
              onScramble: _scrambleCube,
              onMove: _performMove,
              isVertical: isWide,
            );

            Widget mainContent;
            if (isWide) {
              mainContent = Row(
                children: [
                  Expanded(child: cubeArea),
                  SizedBox(
                    width: 350,
                    child: controlsArea,
                  ),
                ],
              );
            } else {
              mainContent = Column(
                children: [
                  Expanded(child: cubeArea),
                  controlsArea,
                ],
              );
            }

            return Stack(
              children: [
                mainContent,
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2, // blast downwards
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.1,
                    colors: const [
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.yellow,
                      Colors.orange,
                      Colors.white,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}
