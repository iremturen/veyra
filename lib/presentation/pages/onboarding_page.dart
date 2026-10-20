import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_image_urls.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/presentation/cubits/onboarding_cubit.dart';
import 'package:veyra/presentation/widgets/onboarding/onboarding_intro_view.dart';
import 'package:veyra/presentation/widgets/onboarding/onboarding_page_indicator.dart';
import 'package:veyra/presentation/widgets/onboarding/onboarding_welcome_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  final List<OnboardingContent> _pages = const [
    OnboardingContent(
      imageUrl: AppImageUrls.onboardingStory,
      title: AppStrings.onboardingTitleOne,
      description: AppStrings.onboardingDescriptionOne,
    ),
    OnboardingContent(
      imageUrl: AppImageUrls.onboardingFriends,
      title: AppStrings.onboardingTitleTwo,
      description: AppStrings.onboardingDescriptionTwo,
    ),
  ];

  void _nextPage() {
    if (!_pageController.hasClients) return;

    _pageController.nextPage(
      duration: const Duration(
        milliseconds: AppDimensions.onboardingPageTransitionDurationMs,
      ),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, int>(
        builder: (context, currentPage) {
          return CustomScaffold(
            model: CustomScaffoldModel(
              body: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: context.read<OnboardingCubit>().changePage,
                    children: [
                      for (final content in _pages)
                        OnboardingIntroView(
                          content: content,
                          onNext: _nextPage,
                        ),
                      const OnboardingWelcomeView(),
                    ],
                  ),
                  if (currentPage < _pages.length)
                    Positioned(
                      bottom: AppDimensions.spacingLarge,
                      left:
                          AppDimensions.onboardingPageIndicatorHorizontalInset,
                      right:
                          AppDimensions.onboardingPageIndicatorHorizontalInset,
                      child: OnboardingPageIndicator(
                        currentPage: currentPage,
                        pageCount:
                            _pages.length +
                            AppDimensions.onboardingWelcomePageCount,
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
