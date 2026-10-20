import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/custom_icon_model.dart';
import '../models/custom_navigation_bar_model.dart';
import 'custom_icon.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({required this.model, super.key});

  final CustomNavigationBarModel model;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: model.selectedIndex,
      onDestinationSelected: model.onDestinationSelected,
      backgroundColor: model.backgroundColor ?? AppColors.background,
      indicatorColor:
          model.indicatorColor ??
          AppColors.primary.withValues(
            alpha: AppDimensions.navigationBarIndicatorOpacity,
          ),
      destinations: model.items.map((item) {
        return NavigationDestination(
          icon: CustomIcon(model: CustomIconModel(icon: item.icon)),
          selectedIcon: item.selectedIcon == null
              ? null
              : CustomIcon(model: CustomIconModel(icon: item.selectedIcon!)),
          label: item.label,
        );
      }).toList(),
    );
  }
}
