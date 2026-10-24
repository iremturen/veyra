import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/cubits/feed/feed_cubit.dart';
import 'package:veyra/presentation/widgets/post/post_card.dart';

class HomeFeedView extends StatelessWidget {
  const HomeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return switch (state.status) {
          FeedStatus.initial || FeedStatus.loading => const Center(
            child: CupertinoActivityIndicator(
              radius: AppDimensions.activityIndicatorRadius,
              color: AppColors.primary,
            ),
          ),
          FeedStatus.failure => _FeedMessage(
            message: state.errorMessage?.isNotEmpty == true
                ? state.errorMessage!
                : AppStrings.feedLoadFailed,
            action: CustomButton(
              model: CustomButtonModel(
                text: AppStrings.retry,
                onPressed: context.read<FeedCubit>().watchPosts,
                width: AppDimensions.retryButtonWidth,
                height: AppDimensions.buttonHeight,
              ),
            ),
          ),
          FeedStatus.loaded when state.posts.isEmpty => const _FeedMessage(
            message: AppStrings.feedEmpty,
          ),
          FeedStatus.loaded => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: AppDimensions.spacingMedium,
              bottom:
                  AppDimensions.navigationBarHeight +
                  AppDimensions.spacingLarge,
            ),
            itemCount: state.posts.length,
            separatorBuilder: (_, _) => const Divider(
              height: AppDimensions.spacingExtraLarge,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) => PostCard(post: state.posts[index]),
          ),
        };
      },
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimensions.spacingMedium,
          children: [
            CustomText(
              model: CustomTextModel(
                text: message,
                style: const TextStyle(color: AppColors.textSecondary),
                fontSize: AppFontSize.small,
                textAlign: TextAlign.center,
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
