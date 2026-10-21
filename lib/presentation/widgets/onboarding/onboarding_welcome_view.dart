import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/pages/register_page.dart';
import 'package:veyra/presentation/pages/sign_in_page.dart';

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
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, screenConstraints) {
          final heroHeight = ((screenConstraints.maxHeight - topInset) * 0.39)
              .clamp(210.0, 330.0)
              .toDouble();

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroHeight + topInset,
                child: _buildHeroBackground(),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, contentConstraints) =>
                      SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: contentConstraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildWelcomeContent(heroHeight),
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
          stops: [0.05, 0.95],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.borderRadius),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -72, right: -46, child: _ambientCircle(210, 0.10)),
          Positioned(left: -88, bottom: -118, child: _ambientCircle(240, 0.08)),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: CustomText(
                model: CustomTextModel(
                  text: AppStrings.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(double heroHeight) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: heroHeight + 40,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5FA),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(bounds),
                        child: CustomText(
                          model: CustomTextModel(
                            text: 'V',
                            style: const TextStyle(color: Colors.white),
                            fontSize: AppFontSize.title,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingLarge,
                  36,
                  AppDimensions.spacingLarge,
                  AppDimensions.spacingLarge,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          model: CustomTextModel(
                            text: AppStrings.onboardingWelcomeTitle,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            fontSize: AppFontSize.title,
                            fontWeight: AppFontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        CustomText(
                          model: CustomTextModel(
                            text: AppStrings.onboardingWelcomeDescription,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            fontSize: AppFontSize.medium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
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
                              height: 56,
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadius,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMedium),
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
                              height: 56,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ambientCircle(double diameter, double opacity) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 1,
        ),
      ),
    );
  }
}
