import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AppColors {
  // Shared colors
  static const Color primary = Color(0xFF242156);
  static const Color secondary = Color(0xFFf1af25);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);

  // Dynamic background
  static Color get background => Get.isDarkMode
      ? const Color(0xFFebf0f4)
      : const Color(0xFFebf0f4);

  static Color get cardBackground => Get.isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);

  static Color get textPrimary => Get.isDarkMode
      ? Colors.white
      : const Color(0xFF000000);
}
