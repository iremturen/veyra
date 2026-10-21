import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/custom_app_bar_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({required this.model, super.key});

  final CustomAppBarModel model;

  @override
  Widget build(BuildContext context) {
    final trailing = model.actions.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: model.actions);

    return CupertinoNavigationBar(
      middle: model.title,
      leading: model.leading,
      trailing: trailing,
      automaticallyImplyLeading: model.automaticallyImplyLeading,
      backgroundColor: model.backgroundColor ?? AppColors.background,
      border: model.showBottomBorder
          ? Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.45),
                width: 0.5,
              ),
            )
          : null,
      transitionBetweenRoutes: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
