import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'cubie.dart';

class CubeState {
  List<Cubie> cubies = [];

  CubeState() {
    _initializeCube();
  }

  void _initializeCube() {
    cubies.clear();
    int id = 0;
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          cubies.add(Cubie(
            id: id++,
            x: x.toDouble(),
            y: y.toDouble(),
            z: z.toDouble(),
            // Colors are assigned only to outer faces
            rightColor: x == 1 ? AppColors.cubeRight : null,
            leftColor: x == -1 ? AppColors.cubeLeft : null,
            downColor: y == 1 ? AppColors.cubeDown : null,
            upColor: y == -1 ? AppColors.cubeUp : null,
            frontColor: z == -1 ? AppColors.cubeFront : null,
            backColor: z == 1 ? AppColors.cubeBack : null,
          ));
        }
      }
    }
  }

  // Axis: 0 for X, 1 for Y, 2 for Z
  // Layer: -1, 0, or 1
  // Direction: 1 for clockwise, -1 for counter-clockwise
  void rotateSlice(int axis, int layer, int direction) {
    for (var cubie in cubies) {
      if (axis == 0 && cubie.x.round() == layer) {
        _rotateCubieX(cubie, direction);
      } else if (axis == 1 && cubie.y.round() == layer) {
        _rotateCubieY(cubie, direction);
      } else if (axis == 2 && cubie.z.round() == layer) {
        _rotateCubieZ(cubie, direction);
      }
    }
  }

  void _rotateCubieX(Cubie cubie, int dir) {
    // Rotate Y and Z
    double newY = dir * -cubie.z;
    double newZ = dir * cubie.y;
    cubie.y = newY;
    cubie.z = newZ;

    // Rotate faces
    Color? temp = cubie.upColor;
    if (dir == 1) {
      cubie.upColor = cubie.backColor;
      cubie.backColor = cubie.downColor;
      cubie.downColor = cubie.frontColor;
      cubie.frontColor = temp;
    } else {
      cubie.upColor = cubie.frontColor;
      cubie.frontColor = cubie.downColor;
      cubie.downColor = cubie.backColor;
      cubie.backColor = temp;
    }
  }

  void _rotateCubieY(Cubie cubie, int dir) {
    // Rotate X and Z
    double newX = dir * cubie.z;
    double newZ = dir * -cubie.x;
    cubie.x = newX;
    cubie.z = newZ;

    // Rotate faces
    Color? temp = cubie.frontColor;
    if (dir == 1) {
      cubie.frontColor = cubie.rightColor;
      cubie.rightColor = cubie.backColor;
      cubie.backColor = cubie.leftColor;
      cubie.leftColor = temp;
    } else {
      cubie.frontColor = cubie.leftColor;
      cubie.leftColor = cubie.backColor;
      cubie.backColor = cubie.rightColor;
      cubie.rightColor = temp;
    }
  }

  void _rotateCubieZ(Cubie cubie, int dir) {
    // Rotate X and Y
    double newX = dir * -cubie.y;
    double newY = dir * cubie.x;
    cubie.x = newX;
    cubie.y = newY;

    // Rotate faces
    Color? temp = cubie.upColor;
    if (dir == 1) {
      cubie.upColor = cubie.leftColor;
      cubie.leftColor = cubie.downColor;
      cubie.downColor = cubie.rightColor;
      cubie.rightColor = temp;
    } else {
      cubie.upColor = cubie.rightColor;
      cubie.rightColor = cubie.downColor;
      cubie.downColor = cubie.leftColor;
      cubie.leftColor = temp;
    }
  }

  bool isSolved() {
    for (var cubie in cubies) {
      if (cubie.x.round() == 1 && cubie.rightColor != AppColors.cubeRight) return false;
      if (cubie.x.round() == -1 && cubie.leftColor != AppColors.cubeLeft) return false;
      if (cubie.y.round() == 1 && cubie.downColor != AppColors.cubeDown) return false;
      if (cubie.y.round() == -1 && cubie.upColor != AppColors.cubeUp) return false;
      if (cubie.z.round() == -1 && cubie.frontColor != AppColors.cubeFront) return false;
      if (cubie.z.round() == 1 && cubie.backColor != AppColors.cubeBack) return false;
    }
    return true;
  }
}
