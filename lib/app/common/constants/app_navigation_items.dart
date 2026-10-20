import 'package:flutter/material.dart';

import 'app_strings.dart';
import '../models/custom_navigation_item_model.dart';

class AppNavigationItems {
  static const List<CustomNavigationItemModel> items = [
    CustomNavigationItemModel(
      label: AppStrings.navigationHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationSearch,
      icon: Icons.search,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationCreate,
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationNotifications,
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationProfile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];
}
