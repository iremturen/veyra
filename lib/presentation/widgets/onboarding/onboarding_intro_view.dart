// lib/app/presentation/widgets/onboarding/onboarding_intro_view.dart

import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

class OnboardingContent {
  final String imageUrl;
  final String title;
  final String description;

  const OnboardingContent({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class OnboardingIntroView extends StatelessWidget {
  final OnboardingContent content;
  final VoidCallback? onGetStarted;

  const OnboardingIntroView({
    required this.content,
    this.onGetStarted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = (constraints.maxHeight * 0.48)
              .clamp(180.0, 420.0)
              .toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingLarge,
              AppDimensions.spacingMedium,
              AppDimensions.spacingLarge,
              AppDimensions.onboardingBottomPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                spacing: AppDimensions.spacingMedium,
                children: [
                  CustomText(
                    model: CustomTextModel(
                      text: AppStrings.appName,
                      style: const TextStyle(color: AppColors.primary),
                      fontSize: AppFontSize.medium,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: CustomImage(
                      model: CustomImageModel(
                        imageUrl: content.imageUrl,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadius,
                        ),
                      ),
                    ),
                  ),
                  CustomText(
                    model: CustomTextModel(
                      text: content.title,
                      style: const TextStyle(color: AppColors.textPrimary),
                      fontSize: AppFontSize.large,
                      fontWeight: AppFontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomText(
                    model: CustomTextModel(
                      text: content.description,
                      style: const TextStyle(color: AppColors.textSecondary),
                      fontSize: AppFontSize.medium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (onGetStarted != null)
                    CustomButton(
                      model: CustomButtonModel(
                        text: AppStrings.getStarted,
                        onPressed: onGetStarted,
                        width: double.infinity,
                        height: AppDimensions.authSubmitButtonHeight,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
