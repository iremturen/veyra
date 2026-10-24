import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

class CrashlyticsTestPage extends StatelessWidget {
  const CrashlyticsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      model: CustomScaffoldModel(
        appBar: CustomAppBar(
          model: CustomAppBarModel(
            title: const CustomText(
              model: CustomTextModel(
                text: AppStrings.crashlyticsTest,
                fontSize: AppFontSize.medium,
                fontWeight: AppFontWeight.bold,
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              spacing: AppDimensions.spacingMedium,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.crashlyticsTestDescription,
                    fontSize: AppFontSize.small,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                if (kDebugMode) ...[
                  CustomButton(
                    model: CustomButtonModel(
                      text: AppStrings.crashApp,
                      onPressed: FirebaseCrashlytics.instance.crash,
                      width: double.infinity,
                      height: AppDimensions.authSubmitButtonHeight,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
