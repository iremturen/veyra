// lib/app/presentation/widgets/onboarding/onboarding_welcome_view.dart

import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_image_urls.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_container_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_container.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

class OnboardingWelcomeView extends StatefulWidget {
  const OnboardingWelcomeView({super.key});

  @override
  State<OnboardingWelcomeView> createState() => _OnboardingWelcomeViewState();
}

class _OnboardingWelcomeViewState extends State<OnboardingWelcomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: AppDimensions.onboardingWelcomeAnimationDurationMs,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(
        AppDimensions.onboardingWelcomeSlideStartX,
        AppDimensions.onboardingWelcomeSlideStartY,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        AppDimensions.onboardingWelcomeFadeStart,
        AppDimensions.onboardingWelcomeFadeEnd,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomImage(
          model: CustomImageModel(
            imageUrl: AppImageUrls.onboardingWelcome,
            fit: BoxFit.cover,
          ),
        ),
        ColoredBox(
          color: Colors.black.withValues(
            alpha: AppDimensions.onboardingWelcomeOverlayOpacity,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildWelcomePanel(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomePanel() {
    return CustomContainer(
      model: CustomContainerModel(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLarge,
          AppDimensions.onboardingWelcomePanelTopPadding,
          AppDimensions.spacingLarge,
          AppDimensions.onboardingWelcomePanelBottomPadding,
        ),
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.onboardingWelcomePanelBorderRadius),
        ),
        child: Column(
          spacing: AppDimensions.spacingMedium,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              model: CustomTextModel(
                text: AppStrings.onboardingWelcomeTitle,
                style: TextStyle(color: AppColors.textPrimary),
                fontSize: AppFontSize.large,
                fontWeight: AppFontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ),
            CustomText(
              model: CustomTextModel(
                text: AppStrings.onboardingWelcomeDescription,
                style: const TextStyle(color: AppColors.textSecondary),
                fontSize: AppFontSize.medium,
                textAlign: TextAlign.center,
              ),
            ),
            CustomButton(
              model: CustomButtonModel(
                text: AppStrings.signUp,
                onPressed: () {
                  // Connect to the Sign Up page later.
                },
                width: double.infinity,
              ),
            ),
            CustomButton(
              model: CustomButtonModel(
                text: AppStrings.signIn,
                onPressed: () {
                  // Connect to the Sign In page later.
                },
                width: double.infinity,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.primary,
                border: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
