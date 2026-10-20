import 'package:flutter/material.dart';

class CustomNavigationItemModel {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  const CustomNavigationItemModel({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}
