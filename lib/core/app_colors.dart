import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color seedColor = Colors.deepPurple;

  // Background Gradient
  static const Color backgroundStart = Color(0xFF1a1a2e);
  static const Color backgroundMiddle = Color(0xFF16213e);
  static const Color backgroundEnd = Color(0xFF0f3460);

  // Cube Faces
  static const Color cubeRight = Colors.red;
  static const Color cubeLeft = Colors.orange;
  static const Color cubeDown = Colors.yellow;
  static const Color cubeUp = Colors.white;
  static const Color cubeFront = Colors.green;
  static const Color cubeBack = Colors.blue;

  // Cube Borders
  static const Color cubeBorder = Colors.black;

  // Glassmorphism
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color buttonHover = Colors.white.withOpacity(0.1);
  static Color buttonSplash = Colors.deepPurpleAccent.withOpacity(0.3);
  static Color buttonGradientStart = Colors.white.withOpacity(0.15);
  static Color buttonGradientEnd = Colors.white.withOpacity(0.05);
  static Color buttonShadow = Colors.black.withOpacity(0.1);

  // Confetti
  static const List<Color> confettiColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.white,
  ];
}
