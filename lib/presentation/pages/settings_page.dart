import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      model: CustomScaffoldModel(
        appBar: CustomAppBar(
          model: const CustomAppBarModel(
            title: CustomText(
              model: CustomTextModel(text: AppStrings.settings),
            ),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingLarge),
            child: CustomText(
              model: CustomTextModel(
                text: AppStrings.settingsComingSoon,
                style: TextStyle(color: AppColors.textSecondary),
                fontSize: AppFontSize.small,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
