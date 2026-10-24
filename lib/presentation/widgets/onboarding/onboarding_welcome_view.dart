import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_asset_paths.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_family.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/pages/auth/register_page.dart';
import 'package:veyra/presentation/pages/auth/sign_in_page.dart';
import 'package:veyra/presentation/widgets/onboarding/onboarding_intro_view.dart';

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
  late final Animation<double> _logoScaleAnimation;

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
    _logoScaleAnimation = Tween<double>(
      begin: AppDimensions.onboardingWelcomeLogoInitialScale,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, screenConstraints) {
          final screenHeight = screenConstraints.maxHeight;
          final heroHeight = (screenHeight * 0.55)
              .clamp(280.0, 500.0)
              .toDouble();

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroBackground(heroHeight),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.spacingLarge,
                          AppDimensions.spacingExtraLarge,
                          AppDimensions.spacingLarge,
                          bottomInset,
                        ),
                        child: Column(
                          spacing: AppDimensions.spacingMedium,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              model: CustomTextModel(
                                text: AppStrings.onboardingWelcomeTitle,
                                fontFamily: AppFontFamily.brand,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                                fontSize: AppFontSize.title,
                                fontWeight: AppFontWeight.bold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            CustomText(
                              model: CustomTextModel(
                                text: AppStrings.onboardingWelcomeDescription,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                                fontSize: AppFontSize.small,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppDimensions.spacingExtraLarge,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  model: CustomButtonModel(
                                    text: AppStrings.signUp,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute<void>(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    width: double.infinity,
                                    height: AppDimensions.authSubmitButtonHeight,
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                model: CustomButtonModel(
                                  text: AppStrings.signIn,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute<void>(
                                        builder: (_) => const SignInPage(),
                                      ),
                                    );
                                  },
                                  width: double.infinity,
                                  height: AppDimensions.authSubmitButtonHeight,
                                  backgroundColor: AppColors.background,
                                  foregroundColor: AppColors.primary,
                                  border: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadius,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildHeroBackground(double height) {
    return ClipPath(
      clipper: const OnboardingWaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.primary],
            stops: [0.05, 0.95],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Image.asset(
              AppAssetPaths.veyraLogo,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              semanticLabel: AppStrings.appName,
            ),
          ),
        ),
      ),
    );
  }
}
