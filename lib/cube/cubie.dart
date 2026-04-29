import 'package:flutter/material.dart';

enum FaceType { front, back, up, down, left, right }

class Cubie {
  final int id;
  // Position from -1 to 1 for x, y, z
  double x, y, z;
  
  // Colors for each face. Null means internal (black/invisible)
  Color? frontColor;
  Color? backColor;
  Color? upColor;
  Color? downColor;
  Color? leftColor;
  Color? rightColor;

  Cubie({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    this.frontColor,
    this.backColor,
    this.upColor,
    this.downColor,
    this.leftColor,
    this.rightColor,
  });

  Cubie clone() {
    return Cubie(
      id: id,
      x: x,
      y: y,
      z: z,
      frontColor: frontColor,
      backColor: backColor,
      upColor: upColor,
      downColor: downColor,
      leftColor: leftColor,
      rightColor: rightColor,
    );
  }
}
