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
  final VoidCallback onNext;

  const OnboardingIntroView({
    required this.content,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLarge,
          AppDimensions.spacingLarge,
          AppDimensions.spacingLarge,
          AppDimensions.onboardingBottomPadding,
        ),
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
            Expanded(
              flex: AppDimensions.onboardingImageFlex,
              child: CustomImage(
                model: CustomImageModel(
                  imageUrl: content.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.imageBorderRadius,
                  ),
                ),
              ),
            ),
            CustomText(
              model: CustomTextModel(
                text: content.title,
                style: TextStyle(color: AppColors.textPrimary),
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
            CustomButton(
              model: CustomButtonModel(
                text: AppStrings.next,
                onPressed: onNext,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
