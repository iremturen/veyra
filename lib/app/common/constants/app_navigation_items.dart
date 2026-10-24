import 'package:flutter/cupertino.dart';

import 'app_strings.dart';
import '../models/custom_navigation_item_model.dart';

class AppNavigationItems {
  static const List<CustomNavigationItemModel> items = [
    CustomNavigationItemModel(
      label: AppStrings.navigationHome,
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationSearch,
      icon: CupertinoIcons.search,
      selectedIcon: CupertinoIcons.search,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationNotifications,
      icon: CupertinoIcons.bell,
      selectedIcon: CupertinoIcons.bell_fill,
    ),
    CustomNavigationItemModel(
      label: AppStrings.navigationProfile,
      icon: CupertinoIcons.person,
      selectedIcon: CupertinoIcons.person_fill,
    ),
  ];
}
