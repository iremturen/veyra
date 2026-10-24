import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:veyra/domain/entities/post_comment.dart';
import 'package:veyra/presentation/cubits/comments/comments_cubit.dart';
import 'package:veyra/presentation/widgets/common/user_avatar.dart';

class CommentsBottomSheet extends StatelessWidget {
  const CommentsBottomSheet({required this.postId, super.key});

  final String postId;

  static Future<void> show(BuildContext context, {required String postId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider(
        create: (_) => CommentsCubit(postId: postId)..watchComments(),
        child: CommentsBottomSheet(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state.submitErrorMessage != null) {
          context.showErrorSnackBar(state.submitErrorMessage!);
        }
      },
      child: Container(
        height: screenHeight * AppDimensions.bottomSheetHeightRatio,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadius),
          ),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomInset),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Column(
              children: [
                const _BottomSheetHandle(),
                _BottomSheetHeader(onClose: () => Navigator.of(context).pop()),
                const Divider(color: AppColors.divider, height: 1),
                const Expanded(child: _CommentsBody()),
                const Divider(color: AppColors.divider, height: 1),
                const _CommentInputBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimensions.bottomSheetDragHandleWidth,
        height: AppDimensions.bottomSheetDragHandleHeight,
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(
            AppDimensions.bottomSheetDragHandleRadius,
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  const _BottomSheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: CustomText(
              model: CustomTextModel(
                text: AppStrings.comments,
                fontSize: AppFontSize.medium,
                fontWeight: AppFontWeight.bold,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(AppDimensions.closeButtonSize),
              onPressed: onClose,
              child: const CustomIcon(
                model: CustomIconModel(
                  icon: CupertinoIcons.xmark,
                  size: AppDimensions.closeButtonIconSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsBody extends StatelessWidget {
  const _CommentsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        if (state.status == CommentsStatus.loading && state.comments.isEmpty) {
          return const Center(
            child: CupertinoActivityIndicator(
              color: AppColors.primary,
              radius: AppDimensions.activityIndicatorRadius,
            ),
          );
        }

        if (state.status == CommentsStatus.failure && state.comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.commentsLoadFailed,
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                CupertinoButton(
                  onPressed: () => context.read<CommentsCubit>().watchComments(),
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

        if (state.comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIcon(
                  model: CustomIconModel(
                    icon: CupertinoIcons.chat_bubble,
                    size: AppDimensions.commentEmptyStateIconSize,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.noCommentsYet,
                    fontSize: AppFontSize.medium,
                    fontWeight: AppFontWeight.bold,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingTiny),
                const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.beFirstToComment,
                    fontSize: AppFontSize.small,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingMedium,
          ),
          itemCount: state.comments.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppDimensions.spacingMedium),
          itemBuilder: (context, index) =>
              _CommentItem(comment: state.comments[index]),
        );
      },
    );
  }
}

class _CommentInputBar extends StatefulWidget {
  const _CommentInputBar();

  @override
  State<_CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<_CommentInputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final canPost = _textController.text.trim().isNotEmpty;
    if (canPost != _canPost) {
      setState(() {
        _canPost = canPost;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final cubit = context.read<CommentsCubit>();
    final success = await cubit.addComment(text);
    if (success && mounted) {
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocBuilder<CommentsCubit, CommentsState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingSmall,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UserAvatar(
                userId: currentUser?.uid,
                fallbackPhoto: currentUser?.photoURL,
                size: AppDimensions.commentInputAvatarSize,
              ),
              const SizedBox(width: AppDimensions.spacingSmall),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.commentInputRadius,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: AppDimensions.borderWidthThin,
                    ),
                  ),
                  child: CupertinoTextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    placeholder: AppStrings.addCommentHint,
                    placeholderStyle:
                        const TextStyle(color: AppColors.textSecondary),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppFontSize.body.value,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSmall),
              if (state.isSubmitting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: CupertinoActivityIndicator(
                    color: AppColors.primary,
                    radius: AppDimensions.activityIndicatorSmallRadius,
                  ),
                )
              else
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(40, 36),
                  onPressed: _canPost ? _submitComment : null,
                  child: CustomText(
                    model: CustomTextModel(
                      text: AppStrings.postAction,
                      fontWeight: AppFontWeight.bold,
                      style: TextStyle(
                        color: _canPost
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.comment});

  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          userId: comment.authorId,
          fallbackPhoto: comment.authorPhotoUrl,
          size: AppDimensions.commentAvatarSize,
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: CustomText(
                      model: CustomTextModel(
                        text: comment.authorName,
                        fontSize: AppFontSize.small,
                        fontWeight: AppFontWeight.bold,
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (comment.createdAt case final createdAt?) ...[
                    const SizedBox(width: AppDimensions.borderRadiusSmall),
                    CustomText(
                      model: CustomTextModel(
                        text: createdAt.timeAgo,
                        fontSize: AppFontSize.caption,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMicro),
              CustomText(
                model: CustomTextModel(
                  text: comment.text,
                  fontSize: AppFontSize.body,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
