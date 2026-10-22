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
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/data/services/media_download_service.dart';
import 'package:veyra/domain/entities/feed_post.dart';

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
          _avatar(photoUrl),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.noImageToDownload)),
                );
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
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(AppStrings.downloadingPhoto),
        duration: Duration(seconds: 1),
      ),
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

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _avatar(String? photoUrl) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: AppDimensions.postAvatarSize,
          height: AppDimensions.postAvatarSize,
          child: CustomIcon(
            model: CustomIconModel(
              icon: CupertinoIcons.person_fill,
              size: AppDimensions.buttonIconSize,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return CustomImage(
      model: CustomImageModel(
        imageUrl: url,
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
