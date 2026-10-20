import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class CustomAppBarModel {
  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBarModel({
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = AppDimensions.appBarElevation,
  });
}
