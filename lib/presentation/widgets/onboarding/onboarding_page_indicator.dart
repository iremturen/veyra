// lib/app/presentation/widgets/onboarding/onboarding_page_indicator.dart

import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingPageIndicator({
    required this.currentPage,
    required this.pageCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(
            milliseconds: AppDimensions.onboardingIndicatorAnimationDurationMs,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.onboardingIndicatorSpacing,
          ),
          height: AppDimensions.onboardingIndicatorHeight,
          width: currentPage == index
              ? AppDimensions.onboardingIndicatorSelectedWidth
              : AppDimensions.onboardingIndicatorWidth,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.primary
                : AppColors.divider,
            borderRadius: BorderRadius.circular(
              AppDimensions.onboardingIndicatorBorderRadius,
            ),
          ),
        ),
      ),
    );
  }
}
