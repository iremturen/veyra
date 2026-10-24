import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:veyra/core/extensions/date_time_extension.dart';
import 'package:veyra/domain/entities/app_notification.dart';
import 'package:veyra/presentation/cubits/notifications/notifications_cubit.dart';
import 'package:veyra/presentation/widgets/common/user_avatar.dart';
import 'package:veyra/presentation/widgets/post/comments_bottom_sheet.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state.status == NotificationsStatus.loading &&
            state.notifications.isEmpty) {
          return const Center(
            child: CupertinoActivityIndicator(
              color: AppColors.primary,
              radius: AppDimensions.activityIndicatorRadius,
            ),
          );
        }

        if (state.status == NotificationsStatus.failure &&
            state.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.notificationsLoadFailed,
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                CupertinoButton(
                  onPressed: () =>
                      context.read<NotificationsCubit>().watchNotifications(),
                  child: const CustomText(
                    model: CustomTextModel(
                      text: AppStrings.retry,
                      fontWeight: AppFontWeight.bold,
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLarge,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcon(
                    model: CustomIconModel(
                      icon: CupertinoIcons.bell,
                      size: AppDimensions.emptyStateIconSize,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  const CustomText(
                    model: CustomTextModel(
                      text: AppStrings.noNotificationsYet,
                      fontSize: AppFontSize.medium,
                      fontWeight: AppFontWeight.bold,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  const CustomText(
                    model: CustomTextModel(
                      text: AppStrings.noNotificationsSubtitle,
                      fontSize: AppFontSize.small,
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMedium,
            AppDimensions.spacingMedium,
            AppDimensions.spacingMedium,
            AppDimensions.navigationBarHeight + AppDimensions.spacingLarge,
          ),
          itemCount: state.notifications.length,
          separatorBuilder: (context, index) =>
              const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
          itemBuilder: (context, index) {
            final notification = state.notifications[index];
            return _NotificationTile(notification: notification);
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  void _onTap(BuildContext context) {
    if (notification.isComment && notification.postId.isNotEmpty) {
      CommentsBottomSheet.show(context, postId: notification.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingTiny,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              userId: notification.senderId,
              fallbackPhoto: notification.senderPhotoUrl,
              size: AppDimensions.notificationAvatarSize,
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: AppFontSize.body.value,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '${notification.senderName} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: notification.message,
                        ),
                      ],
                    ),
                  ),
                  if (notification.createdAt case final createdAt?) ...[
                    const SizedBox(height: AppDimensions.spacingMicro),
                    CustomText(
                      model: CustomTextModel(
                        text: createdAt.timeAgo,
                        fontSize: AppFontSize.meta,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (notification.postImageUrl case final imageUrl?
                when imageUrl.trim().isNotEmpty) ...[
              const SizedBox(width: AppDimensions.spacingSmall),
              CustomImage(
                model: CustomImageModel(
                  imageUrl: imageUrl.trim(),
                  width: AppDimensions.notificationImageSize,
                  height: AppDimensions.notificationImageSize,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusSmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
