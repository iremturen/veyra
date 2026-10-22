import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/cubits/explore_banner_cubit.dart';
import 'package:veyra/presentation/cubits/feed_cubit.dart';
import 'package:veyra/presentation/widgets/main/explore_banner.dart';
import 'package:veyra/presentation/widgets/main/explore_search_bar.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppDimensions.spacingMedium,
          right: AppDimensions.spacingMedium,
          top: AppDimensions.spacingMedium,
          bottom:
              AppDimensions.navigationBarHeight + AppDimensions.spacingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ExploreSearchBar(),
            BlocBuilder<ExploreBannerCubit, ExploreBannerState>(
              builder: (context, state) => state.config.isHidden
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.spacingMedium,
                      ),
                      child: ExploreBanner(config: state.config),
                    ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            BlocBuilder<FeedCubit, FeedState>(
              builder: (context, state) {
                return switch (state.status) {
                  FeedStatus.initial || FeedStatus.loading => const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingExtraLarge * 2,
                      ),
                      child: Center(
                        child: CupertinoActivityIndicator(
                          radius: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  FeedStatus.failure => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingExtraLarge * 2,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: AppDimensions.spacingMedium,
                          children: [
                            const CustomText(
                              model: CustomTextModel(
                                text: AppStrings.feedLoadFailed,
                                fontSize: AppFontSize.compact,
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            CustomButton(
                              model: CustomButtonModel(
                                text: AppStrings.retry,
                                onPressed: context.read<FeedCubit>().watchPosts,
                                width: 140,
                                height: AppDimensions.buttonHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  FeedStatus.loaded => () {
                      final posts = state.posts
                          .where(
                            (post) =>
                                post.imageUrl != null &&
                                post.imageUrl!.trim().isNotEmpty,
                          )
                          .toList(growable: false);

                      if (posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingExtraLarge * 2,
                          ),
                          child: Center(
                            child: CustomText(
                              model: CustomTextModel(
                                text: AppStrings.exploreNoPosts,
                                fontSize: AppFontSize.compact,
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              AppDimensions.profileGridCrossAxisCount,
                          crossAxisSpacing: AppDimensions.spacingSmall / 2,
                          mainAxisSpacing: AppDimensions.spacingSmall / 2,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return CustomImage(
                            model: CustomImageModel(
                              imageUrl: post.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.zero,
                            ),
                          );
                        },
                      );
                    }(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

typedef ExploreView = ExplorePage;
