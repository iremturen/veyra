import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_asset_paths.dart';
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
                child: _buildHeroBackground(heroHeight + topInset),
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

  Widget _buildHeroBackground(double height) {
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
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => ScaleTransition(
            scale: _logoScaleAnimation,
            child: Image.asset(
              AppAssetPaths.veyraLogo,
              width: constraints.maxWidth,
              height: height,
              fit: BoxFit.cover,
              semanticLabel: AppStrings.appName,
            ),
          ),
        ),
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
            SizedBox(height: (heroHeight - 48).clamp(180.0, 282.0)),
            Expanded(
              child: ClipPath(
                clipper: const _WelcomePanelClipper(),
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacingLarge,
                    62,
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
                        spacing: AppDimensions.spacingMedium,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePanelClipper extends CustomClipper<Path> {
  const _WelcomePanelClipper();

  @override
  Path getClip(Size size) {
    const edgeHeight = 48.0;
    final path = Path()
      ..moveTo(0, edgeHeight)
      ..cubicTo(
        size.width * 0.24,
        edgeHeight,
        size.width * 0.30,
        0,
        size.width * 0.5,
        0,
      )
      ..cubicTo(
        size.width * 0.70,
        0,
        size.width * 0.76,
        edgeHeight,
        size.width,
        edgeHeight,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
