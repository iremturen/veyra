import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_container_model.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_container.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/core/extensions/snack_bar_extension.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/cubits/post/create_post_cubit.dart';
import 'package:veyra/presentation/widgets/common/user_avatar.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({required this.initialImage, super.key});

  final XFile initialImage;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  late final CreatePostCubit _createPostCubit;

  @override
  void initState() {
    super.initState();
    _createPostCubit = CreatePostCubit(initialImage: widget.initialImage);
  }

  @override
  void dispose() {
    _captionController.dispose();
    _createPostCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _createPostCubit,
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success) {
            context.showSnackBar(AppStrings.postShared);
            Navigator.of(context).pop();
          } else if (state.status == CreatePostStatus.failure &&
              state.message != null) {
            context.showErrorSnackBar(state.message!);
          }
        },
        builder: (context, postState) => CustomScaffold(
          model: CustomScaffoldModel(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              model: CustomAppBarModel(
                title: const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.newPost,
                    fontSize: AppFontSize.medium,
                    fontWeight: AppFontWeight.normal,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  child: const Icon(
                    CupertinoIcons.back,
                    color: AppColors.textPrimary,
                  ),
                ),
                backgroundColor: AppColors.background,
                automaticallyImplyLeading: false,
              ),
            ),
            safeArea: false,
            body: SafeArea(
              child: Column(
                spacing: AppDimensions.spacingMedium,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.spacingLarge,
                        AppDimensions.spacingMedium,
                        AppDimensions.spacingLarge,
                        AppDimensions.spacingLarge,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppDimensions.authFormMaxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppDimensions.spacingMedium,
                            children: [
                              _photoPicker(
                                postState,
                                context.read<CreatePostCubit>(),
                              ),
                              _captionComposer(postState),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingLarge,
                      AppDimensions.spacingSmall,
                      AppDimensions.spacingLarge,
                      AppDimensions.spacingMedium,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppDimensions.authFormMaxWidth,
                        ),
                        child: CustomButton(
                          model: CustomButtonModel(
                            text: AppStrings.sharePost,
                            onPressed: postState.selectedImage == null
                                ? null
                                : () =>
                                      context.read<CreatePostCubit>().sharePost(
                                        caption: _captionController.text,
                                      ),
                            width: double.infinity,
                            height: AppDimensions.authSubmitButtonHeight,
                            isLoading: postState.isLoading,
                            isEnabled: postState.selectedImage != null,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoPicker(CreatePostState postState, CreatePostCubit cubit) {
    return GestureDetector(
      onTap: postState.isLoading ? null : cubit.selectPhoto,
      child: CustomContainer(
        model: CustomContainerModel(
          color: AppColors.placeholderBackground,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(color: AppColors.divider),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            child: AspectRatio(
              aspectRatio: AppDimensions.createPostPreviewAspectRatio,
              child: postState.selectedImage == null
                  ? const ColoredBox(
                      color: AppColors.placeholderBackground,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppDimensions.spacingMedium,
                        children: [
                          CustomIcon(
                            model: CustomIconModel(
                              icon: CupertinoIcons.photo_on_rectangle,
                              size: AppDimensions.emailVerificationIconSize,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          CustomText(
                            model: CustomTextModel(
                              text: AppStrings.choosePhotoHint,
                              fontSize: AppFontSize.small,
                              fontWeight: AppFontWeight.medium,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ColoredBox(
                      color: AppColors.secondarySoft,
                      child: Image.file(
                        File(postState.selectedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: CustomIcon(
                                model: CustomIconModel(
                                  icon: CupertinoIcons.photo,
                                  size: AppDimensions.emailVerificationIconSize,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _captionComposer(CreatePostState postState) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Row(
      spacing: AppDimensions.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          userId: FirebaseAuth.instance.currentUser?.uid,
          fallbackPhoto: photoUrl,
          size: AppDimensions.postAvatarSize,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
                width: AppDimensions.borderWidthThin,
              ),
            ),
            child: CupertinoTextField(
              controller: _captionController,
              enabled: !postState.isLoading,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: AppDimensions.createPostCaptionMaxLines,
              cursorColor: AppColors.primary,
              placeholder: AppStrings.optionalCaption,
              placeholderStyle: const TextStyle(color: AppColors.textSecondary),
              style: const TextStyle(color: AppColors.textPrimary),
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
