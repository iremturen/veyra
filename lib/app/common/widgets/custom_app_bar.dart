import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/custom_app_bar_model.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBar({
    required this.model,
    super.key,
  });

  final CustomAppBarModel model;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: model.title,
      leading: model.leading,
      actions: model.actions,
      centerTitle: model.centerTitle,
      automaticallyImplyLeading:
          model.automaticallyImplyLeading,
      backgroundColor:
          model.backgroundColor ?? AppColors.background,
      foregroundColor:
          model.foregroundColor ?? AppColors.textPrimary,
      elevation: model.elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}