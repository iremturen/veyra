import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/cubits/feed/feed_cubit.dart';
import 'package:veyra/presentation/pages/profile/edit_profile_page.dart';
import 'package:veyra/presentation/pages/settings/settings_page.dart';
import 'package:veyra/presentation/widgets/common/user_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: CustomText(
          model: CustomTextModel(
            text: AppStrings.profileUnavailable,
            fontSize: AppFontSize.compact,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        final userPosts = state.posts
            .where((post) => post.authorId == user.uid)
            .toList(growable: false);
        final imagePosts = userPosts
            .where((post) => post.imageUrl?.isNotEmpty == true)
            .toList(growable: false);
        final totalLikes = userPosts.fold<int>(
          0,
          (total, post) => total + post.likeCount,
        );

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                user: user,
                postCount: userPosts.length,
                likeCount: totalLikes,
              ),
            ),
            if (state.status == FeedStatus.initial ||
                state.status == FeedStatus.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CupertinoActivityIndicator(color: AppColors.primary),
                ),
              )
            else if (state.status == FeedStatus.failure)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppDimensions.spacingMedium,
                      children: [
                        const CustomText(
                          model: CustomTextModel(
                            text: AppStrings.profileLoadFailed,
                            fontSize: AppFontSize.compact,
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        CustomButton(
                          model: CustomButtonModel(
                            text: AppStrings.retry,
                            onPressed: context.read<FeedCubit>().watchPosts,
                            width: AppDimensions.retryButtonWidth,
                            height: AppDimensions.buttonHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (imagePosts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CustomText(
                    model: CustomTextModel(
                      text: AppStrings.profileNoPosts,
                      fontSize: AppFontSize.compact,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingSmall,
                  bottom:
                      AppDimensions.navigationBarHeight +
                      AppDimensions.spacingLarge,
                ),
                sliver: SliverGrid.builder(
                  itemCount: imagePosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppDimensions.profileGridCrossAxisCount,
                    crossAxisSpacing: AppDimensions.spacingSmall / 2,
                    mainAxisSpacing: AppDimensions.spacingSmall / 2,
                  ),
                  itemBuilder: (context, index) =>
                      _ProfilePostTile(post: imagePosts[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.postCount,
    required this.likeCount,
  });

  final User user;
  final int postCount;
  final int? likeCount;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final bio = data?['bio'] as String?;
        final firestorePhoto = data?['photoUrl'] as String?;
        final photoUrl = firestorePhoto?.trim().isNotEmpty == true
            ? firestorePhoto!.trim()
            : user.photoURL;
        final firestoreUsername = data?['username'] as String?;
        final displayName = user.displayName?.trim();
        final emailName = user.email?.split('@').first.trim();
        final username = firestoreUsername?.trim().isNotEmpty == true
            ? firestoreUsername!.trim()
            : displayName?.isNotEmpty == true
                ? displayName!
                : emailName?.isNotEmpty == true
                    ? emailName!
                    : AppStrings.feedMemberFallback;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMedium,
            AppDimensions.spacingMedium,
            AppDimensions.spacingMedium,
            AppDimensions.spacingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimensions.spacingMedium,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    userId: user.uid,
                    fallbackPhoto: photoUrl,
                    size: AppDimensions.profileAvatarSize,
                  ),
                  const SizedBox(width: AppDimensions.spacingLarge),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfileStat(
                          value: '$postCount',
                          label: AppStrings.profilePosts,
                        ),
                        _ProfileStat(
                          value: likeCount?.toString() ?? '—',
                          label: AppStrings.profileLikes,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppDimensions.spacingTiny,
                children: [
                  CustomText(
                    model: CustomTextModel(
                      text: username,
                      fontSize: AppFontSize.small,
                      fontWeight: AppFontWeight.bold,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (bio != null && bio.trim().isNotEmpty)
                    CustomText(
                      model: CustomTextModel(
                        text: bio.trim(),
                        fontSize: AppFontSize.small,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
              CustomButton(
                model: CustomButtonModel(
                  text: AppStrings.profileEdit,
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const EditProfilePage(),
                    ),
                  ),
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primary,
                  icon: CupertinoIcons.pencil,
                  border: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Row(
                spacing: AppDimensions.spacingMedium,
                children: [
                  Expanded(
                    child: CustomButton(
                      model: CustomButtonModel(
                        text: AppStrings.settings,
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const SettingsPage(),
                          ),
                        ),
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                        icon: CupertinoIcons.gear,
                        border: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      model: CustomButtonModel(
                        text: AppStrings.logout,
                        onPressed: () => context.read<AuthCubit>().signOut(),
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                        icon: CupertinoIcons.square_arrow_left,
                        border: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppDimensions.spacingSmall / 2,
      children: [
        CustomText(
          model: CustomTextModel(
            text: value,
            fontSize: AppFontSize.medium,
            fontWeight: AppFontWeight.bold,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
        CustomText(
          model: CustomTextModel(
            text: label,
            fontSize: AppFontSize.compact,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ProfilePostTile extends StatelessWidget {
  const _ProfilePostTile({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return CustomImage(
      model: CustomImageModel(
        imageUrl: post.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
