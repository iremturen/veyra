import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/domain/entities/feed_post.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({required this.post, super.key});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      child: Row(
        children: [
          _avatar(),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  model: CustomTextModel(
                    text: post.authorName,
                    fontSize: AppFontSize.small,
                    fontWeight: AppFontWeight.bold,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.createdAt != null)
                  CustomText(
                    model: CustomTextModel(
                      text: _formatDate(post.createdAt!),
                      style: const TextStyle(color: AppColors.textSecondary),
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
          Semantics(
            label: AppStrings.postMoreOptions,
            child: CustomIcon(
              model: CustomIconModel(
                icon: CupertinoIcons.ellipsis,
                size: AppDimensions.postActionIconSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final imageUrl = post.authorPhotoUrl;
    if (imageUrl == null) {
      return const CircleAvatar(
        radius: AppDimensions.postAvatarSize / 2,
        backgroundColor: AppColors.divider,
        child: CustomIcon(
          model: CustomIconModel(
            icon: CupertinoIcons.person_fill,
            size: AppDimensions.buttonIconSize,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return CustomImage(
      model: CustomImageModel(
        imageUrl: imageUrl,
        width: AppDimensions.postAvatarSize,
        height: AppDimensions.postAvatarSize,
        borderRadius: BorderRadius.circular(AppDimensions.postAvatarSize / 2),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final elapsed = DateTime.now().difference(value);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}m';
    if (elapsed.inDays < 1) return '${elapsed.inHours}h';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d';
    return '${value.day}/${value.month}/${value.year}';
  }
}
