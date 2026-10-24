import 'package:flutter/cupertino.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';

class PostActions extends StatelessWidget {
  const PostActions({
    this.isLiked = false,
    this.onLikePressed,
    this.onCommentPressed,
    super.key,
  });

  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      child: Row(
        spacing: AppDimensions.spacingMedium,
        children: [
          _ActionIcon(
            label: AppStrings.postLike,
            icon: isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: isLiked ? AppColors.error : AppColors.textPrimary,
            onPressed: onLikePressed,
          ),
          _ActionIcon(
            label: AppStrings.postComment,
            icon: CupertinoIcons.chat_bubble,
            onPressed: onCommentPressed,
          ),
          const _ActionIcon(
            label: AppStrings.postShare,
            icon: CupertinoIcons.paperplane,
          ),
          const Spacer(),
          const _ActionIcon(
            label: AppStrings.postSave,
            icon: CupertinoIcons.bookmark,
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.label,
    required this.icon,
    this.color = AppColors.textPrimary,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconWidget = CustomIcon(
      model: CustomIconModel(
        icon: icon,
        size: AppDimensions.postActionIconSize,
        color: color,
      ),
    );

    return Semantics(
      label: label,
      child: onPressed != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(AppDimensions.postActionIconSize),
              onPressed: onPressed,
              child: iconWidget,
            )
          : iconWidget,
    );
  }
}
