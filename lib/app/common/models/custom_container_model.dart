import 'package:flutter/material.dart';

class CustomContainerModel {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final AlignmentGeometry? alignment;

  const CustomContainerModel({
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.alignment,
  });
}
