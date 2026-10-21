import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/widgets/post/post_actions.dart';
import 'package:veyra/presentation/widgets/post/post_header.dart';
import 'package:veyra/presentation/widgets/post/post_image.dart';

class PostCard extends StatelessWidget {
  final FeedPost post;

  const PostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostHeader(post: post),
        if (post.imageUrl case final imageUrl?) PostImage(imageUrl: imageUrl),
        const PostActions(),
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium,
              0,
              AppDimensions.spacingMedium,
              AppDimensions.spacingSmall,
            ),
            child: CustomText(
              model: CustomTextModel(
                text: post.caption,
                fontSize: AppFontSize.small,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
      ],
    );
  }
}
