import 'package:flutter/cupertino.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
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
          model: CustomAppBarModel(
            title: const CustomText(
              model: CustomTextModel(
                text: AppStrings.settings,
                fontSize: AppFontSize.medium,
                fontWeight: AppFontWeight.normal,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            leading: CupertinoButton(
              onPressed: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
            ),
            automaticallyImplyLeading: false,
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
