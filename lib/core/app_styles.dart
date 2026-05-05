import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Container Decorations
  static final BoxDecoration backgroundGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.backgroundStart,
        AppColors.backgroundMiddle,
        AppColors.backgroundEnd,
      ],
    ),
  );

  static final BoxDecoration glassContainerVertical = BoxDecoration(
    color: AppColors.glassBackground,
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1.5,
    ),
    borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
  );

  static final BoxDecoration glassContainerHorizontal = BoxDecoration(
    color: AppColors.glassBackground,
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1.5,
    ),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
  );

  // Button Styles
  static final ButtonStyle scrambleButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.2),
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
  );

  static BoxDecoration moveButtonDecoration(bool isHovered) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.buttonGradientStart,
          AppColors.buttonGradientEnd,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.glassBorder),
      boxShadow: [
        BoxShadow(
          color: AppColors.buttonShadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Text Styles
  static const TextStyle primeToggleStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle moveButtonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
}
