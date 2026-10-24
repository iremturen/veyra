import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/core/extensions/date_time_extension.dart';
import 'package:veyra/core/extensions/snack_bar_extension.dart';
import 'package:veyra/data/services/media_download_service.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/widgets/common/user_avatar.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.post,
    this.mediaDownloadService = const MediaDownloadService(),
    super.key,
  });

  final FeedPost post;
  final MediaDownloadService mediaDownloadService;

  @override
  Widget build(BuildContext context) {
    final authorId = post.authorId?.trim();
    final fallbackPhoto = post.authorPhotoUrl?.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (authorId == null || authorId.isEmpty) {
      return _buildContent(
        context: context,
        photoUrl: fallbackPhoto,
        authorName: post.authorName,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final firestorePhoto = userData?['photoUrl'] as String?;
        final resolvedPhoto = (firestorePhoto?.trim().isNotEmpty == true)
            ? firestorePhoto!.trim()
            : (fallbackPhoto?.isNotEmpty == true)
                ? fallbackPhoto
                : (authorId == currentUser?.uid ? currentUser?.photoURL : null);

        final firestoreUsername = userData?['username'] as String?;
        final resolvedName = (firestoreUsername?.trim().isNotEmpty == true)
            ? firestoreUsername!.trim()
            : post.authorName;

        return _buildContent(
          context: context,
          photoUrl: resolvedPhoto,
          authorName: resolvedName,
        );
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required String? photoUrl,
    required String authorName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      child: Row(
        children: [
          UserAvatar(
            userId: post.authorId,
            fallbackPhoto: photoUrl,
            size: AppDimensions.postAvatarSize,
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  model: CustomTextModel(
                    text: authorName,
                    fontSize: AppFontSize.small,
                    fontWeight: AppFontWeight.bold,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.createdAt case final createdAt?)
                  CustomText(
                    model: CustomTextModel(
                      text: createdAt.timeAgo,
                      style: const TextStyle(color: AppColors.textSecondary),
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
          Semantics(
            label: AppStrings.postMoreOptions,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(
                AppDimensions.postActionIconSize + 16,
              ),
              onPressed: () => _showOptions(context),
              child: const CustomIcon(
                model: CustomIconModel(
                  icon: CupertinoIcons.ellipsis,
                  size: AppDimensions.postActionIconSize,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final imageUrl = post.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              if (hasImage) {
                _downloadImage(context, imageUrl);
              } else {
                context.showSnackBar(AppStrings.noImageToDownload);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIcon(
                  model: CustomIconModel(
                    icon: CupertinoIcons.arrow_down_to_line,
                    size: AppDimensions.buttonIconSize,
                    color:
                        hasImage ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                CustomText(
                  model: CustomTextModel(
                    text: AppStrings.downloadImage,
                    fontWeight: AppFontWeight.medium,
                    style: TextStyle(
                      color:
                          hasImage ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const CustomText(
            model: CustomTextModel(
              text: AppStrings.cancel,
              fontWeight: AppFontWeight.bold,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBarMessage(
      AppStrings.downloadingPhoto,
      duration: const Duration(seconds: 1),
    );

    final result = await mediaDownloadService.downloadAndSaveImage(imageUrl);

    if (!context.mounted) return;

    final message = switch (result) {
      MediaDownloadResult.success => AppStrings.photoDownloaded,
      MediaDownloadResult.permissionDenied => AppStrings.photoPermissionDenied,
      MediaDownloadResult.storageFull => AppStrings.storageFull,
      MediaDownloadResult.networkError => AppStrings.networkError,
      MediaDownloadResult.notFound => AppStrings.noImageToDownload,
      MediaDownloadResult.unsupportedFormat ||
      MediaDownloadResult.failed =>
        AppStrings.photoDownloadFailed,
    };

    final isError = result != MediaDownloadResult.success;
    messenger.showSnackBarMessage(message, isError: isError);
  }
}
