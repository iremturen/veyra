import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomText(
        model: CustomTextModel(
          text: AppStrings.navigationNotifications,
          fontSize: AppFontSize.medium,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

typedef NotificationsView = NotificationsPage;
