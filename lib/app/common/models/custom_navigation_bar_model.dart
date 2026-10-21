import 'package:flutter/material.dart';
import 'package:veyra/app/common/models/custom_navigation_item_model.dart';

class CustomNavigationBarModel {
  const CustomNavigationBarModel({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onCreatePressed,
    this.backgroundColor,
    this.indicatorColor,
  });

  final List<CustomNavigationItemModel> items;
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreatePressed;
  final Color? backgroundColor;
  final Color? indicatorColor;
}
