import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_font_weight.dart';

class CustomButtonModel {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? border;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsetsGeometry? padding;
  final AppFontWeight fontWeight;

  const CustomButtonModel({
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.borderRadius,
    this.border,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.fontWeight = AppFontWeight.bold,
  });
}
