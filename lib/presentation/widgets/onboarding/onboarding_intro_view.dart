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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageHeight = (screenHeight * 0.55)
            .clamp(280.0, 500.0)
            .toDouble();

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipPath(
                  clipper: const OnboardingWaveClipper(),
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: CustomImage(
                      model: CustomImageModel(
                        imageUrl: content.imageUrl,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacingLarge,
                    AppDimensions.onboardingTopPadding,
                    AppDimensions.spacingLarge,
                    AppDimensions.onboardingBottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: AppDimensions.spacingMedium,
                    children: [
                      Center(
                        child: CustomText(
                          model: CustomTextModel(
                            text: content.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              height: 1.25,
                              letterSpacing: -0.5,
                            ),
                            fontSize: AppFontSize.title,
                            fontWeight: AppFontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Center(
                        child: CustomText(
                          model: CustomTextModel(
                            text: content.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            fontSize: AppFontSize.small,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (onGetStarted != null) ...[
                        const SizedBox(height: AppDimensions.spacingSmall),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingWaveClipper extends CustomClipper<Path> {
  const OnboardingWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.88);

    // Smooth organic wave curve matching the reference design:
    // Gently dips down on the left (~25-30% width) and gracefully sweeps up to the right.
    path.cubicTo(
      size.width * 0.24,
      size.height * 1.09,
      size.width * 0.58,
      size.height * 0.98,
      size.width,
      size.height * 0.82,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
