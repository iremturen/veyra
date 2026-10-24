import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/cubits/feed/feed_cubit.dart';
import 'package:veyra/presentation/widgets/post/comments_bottom_sheet.dart';
import 'package:veyra/presentation/widgets/post/post_actions.dart';
import 'package:veyra/presentation/widgets/post/post_header.dart';
import 'package:veyra/presentation/widgets/post/post_image.dart';

class PostCard extends StatelessWidget {
  final FeedPost post;

  const PostCard({required this.post, super.key});

  void _openComments(BuildContext context) {
    CommentsBottomSheet.show(context, postId: post.id);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = post.isLikedBy(currentUserId);

    return Column(
      spacing: AppDimensions.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostHeader(post: post),
        if (post.imageUrl case final imageUrl?) PostImage(imageUrl: imageUrl),
        PostActions(
          isLiked: isLiked,
          onLikePressed: () => context.read<FeedCubit>().toggleLike(post),
          onCommentPressed: () => _openComments(context),
        ),
        if (post.likeCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium,
            ),
            child: CustomText(
              model: CustomTextModel(
                text:
                    '${post.likeCount} ${post.likeCount == 1 ? AppStrings.likesCountSingular : AppStrings.likesCountPlural}',
                fontSize: AppFontSize.compact,
                fontWeight: AppFontWeight.bold,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium,
            ),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppFontSize.body.value,
                ),
                children: [
                  TextSpan(
                    text: '${post.authorName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: () => _openComments(context),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium,
            ),
            child: CustomText(
              model: CustomTextModel(
                text: AppStrings.viewComments,
                fontSize: AppFontSize.compact,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
