import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC13584);
  static const Color secondary = Color(0xFF833AB4);
  static const Color primarySoft = Color(0xFFFFF2F8);
  static const Color secondarySoft = Color(0xFFF5EFFA);
  static const Color createPostBackground = Color(0xFFFFFBFD);
  static const Color placeholderBackground = Color(0xFFF5F5F5);
  static const List<Color> exploreBannerGradientColors = [
    Color.fromARGB(178, 193, 53, 132),
    Color(0x1AC13584),
  ];

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color divider = Color(0xFFDBDBDB);
  static const Color error = Color(0xFFED4956);
}
