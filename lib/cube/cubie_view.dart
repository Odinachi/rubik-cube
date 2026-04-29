import 'dart:math';
import 'package:flutter/material.dart';
import 'cubie.dart';

class CubieView extends StatelessWidget {
  final Cubie cubie;
  final double size;

  const CubieView({
    Key? key,
    required this.cubie,
    required this.size,
  }) : super(key: key);

  Widget _buildFace(Color? color, Matrix4 transform) {
    if (color == null) {
      return const SizedBox.shrink();
    }
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildInternalFace(Matrix4 transform) {
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final half = size / 2;
    
    // Translation to position the cubie in the 3x3x3 grid
    final Matrix4 positionTransform = Matrix4.identity()
      ..translate(cubie.x * size, cubie.y * size, cubie.z * size);

    return Transform(
      transform: positionTransform,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildInternalFace(Matrix4.identity()..translate(0.0, 0.0, -half)..rotateY(pi)),
          _buildFace(cubie.backColor, Matrix4.identity()..translate(0.0, 0.0, -half)..rotateY(pi)),
          
          _buildInternalFace(Matrix4.identity()..translate(0.0, -half, 0.0)..rotateX(-pi / 2)),
          _buildFace(cubie.upColor, Matrix4.identity()..translate(0.0, -half, 0.0)..rotateX(-pi / 2)),
          
          _buildInternalFace(Matrix4.identity()..translate(0.0, half, 0.0)..rotateX(pi / 2)),
          _buildFace(cubie.downColor, Matrix4.identity()..translate(0.0, half, 0.0)..rotateX(pi / 2)),
          
          _buildInternalFace(Matrix4.identity()..translate(-half, 0.0, 0.0)..rotateY(-pi / 2)),
          _buildFace(cubie.leftColor, Matrix4.identity()..translate(-half, 0.0, 0.0)..rotateY(-pi / 2)),
          
          _buildInternalFace(Matrix4.identity()..translate(half, 0.0, 0.0)..rotateY(pi / 2)),
          _buildFace(cubie.rightColor, Matrix4.identity()..translate(half, 0.0, 0.0)..rotateY(pi / 2)),
          
          _buildInternalFace(Matrix4.identity()..translate(0.0, 0.0, half)),
          _buildFace(cubie.frontColor, Matrix4.identity()..translate(0.0, 0.0, half)),
        ],
      ),
    );
  }
}
