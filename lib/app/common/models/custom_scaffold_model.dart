import 'package:flutter/material.dart';

class CustomScaffoldModel {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;
  final bool extendBody;

  const CustomScaffoldModel({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = false,
    this.extendBody = false,
  });
}
