import 'package:flutter/cupertino.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';

class PostActions extends StatelessWidget {
  const PostActions({super.key});

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
          const _ActionIcon(
            label: AppStrings.postLike,
            icon: CupertinoIcons.heart,
          ),
          const _ActionIcon(
            label: AppStrings.postComment,
            icon: CupertinoIcons.chat_bubble,
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
  const _ActionIcon({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: CustomIcon(
        model: CustomIconModel(
          icon: icon,
          size: AppDimensions.postActionIconSize,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
