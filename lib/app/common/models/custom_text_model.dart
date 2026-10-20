import 'package:flutter/material.dart';

import '../constants/app_font_size.dart';
import '../constants/app_font_weight.dart';

class CustomTextModel {
  final String text;
  final TextStyle? style;
  final AppFontSize? fontSize;
  final AppFontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomTextModel({
    required this.text,
    this.style,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
}
