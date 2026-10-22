import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_field_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/app/common/widgets/custom_text_field.dart';
import 'package:veyra/presentation/cubits/edit_profile_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  late final EditProfileCubit _editProfileCubit;
  final String? _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

  @override
  void initState() {
    super.initState();
    _editProfileCubit = EditProfileCubit()..loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _editProfileCubit.close();
    super.dispose();
  }

  void _handleState(BuildContext context, EditProfileState state) {
    if (state.status == EditProfileStatus.loaded) {
      _usernameController.text = state.username;
      _emailController.text = state.email;
      _bioController.text = state.bio;
    } else if (state.status == EditProfileStatus.saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.profileSaved)));
      Navigator.of(context).pop();
    } else if (state.message != null &&
        (state.status == EditProfileStatus.saveFailure ||
            !state.isUploadingPhoto)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _editProfileCubit,
      child: BlocConsumer<EditProfileCubit, EditProfileState>(
        bloc: _editProfileCubit,
        listener: _handleState,
        builder: (context, state) => CustomScaffold(
          model: CustomScaffoldModel(
            appBar: CustomAppBar(
              model: CustomAppBarModel(
                title: const CustomText(
                  model: CustomTextModel(
                    text: AppStrings.profileEdit,
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
                automaticallyImplyLeading: false,
              ),
            ),
            body: _body(context, state),
            bottomNavigationBar:
                state.status == EditProfileStatus.loaded ||
                    state.status == EditProfileStatus.editing ||
                    state.status == EditProfileStatus.saving ||
                    state.status == EditProfileStatus.saveFailure
                ? SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                      child: CustomButton(
                        model: CustomButtonModel(
                          text: AppStrings.saveChanges,
                          onPressed: state.status == EditProfileStatus.saving ||
                                  state.isUploadingPhoto
                              ? null
                              : () => _editProfileCubit.saveBio(
                                  _bioController.text,
                                ),
                          width: double.infinity,
                          height: AppDimensions.authSubmitButtonHeight,
                          isLoading: state.status == EditProfileStatus.saving,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, EditProfileState state) {
    if (state.status == EditProfileStatus.initial ||
        state.status == EditProfileStatus.loading) {
      return const Center(
        child: CupertinoActivityIndicator(color: AppColors.primary),
      );
    }

    if (state.status == EditProfileStatus.loadFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDimensions.spacingMedium,
            children: [
              CustomText(
                model: CustomTextModel(
                  text: state.message ?? AppStrings.profileDetailsLoadFailed,
                  fontSize: AppFontSize.small,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              CustomButton(
                model: CustomButtonModel(
                  text: AppStrings.retry,
                  onPressed: _editProfileCubit.loadProfile,
                  width: AppDimensions.authSubmitButtonHeight * 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.authFormMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppDimensions.spacingLarge,
              children: [
                _profilePhoto(state),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppDimensions.spacingSmall / 2,
                  children: [
                    CustomTextField(
                      model: CustomTextFieldModel(
                        controller: _usernameController,
                        labelText: AppStrings.username,
                        enabled: false,
                        readOnly: true,
                        suffixIcon: const CustomIcon(
                          model: CustomIconModel(
                            icon: CupertinoIcons.lock_fill,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const CustomText(
                      model: CustomTextModel(
                        text: AppStrings.usernameCannotBeChanged,
                        fontSize: AppFontSize.compact,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppDimensions.spacingSmall / 2,
                  children: [
                    CustomTextField(
                      model: CustomTextFieldModel(
                        controller: _emailController,
                        labelText: AppStrings.email,
                        enabled: false,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: const CustomIcon(
                          model: CustomIconModel(
                            icon: CupertinoIcons.lock_fill,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const CustomText(
                      model: CustomTextModel(
                        text: AppStrings.emailCannotBeChanged,
                        fontSize: AppFontSize.compact,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                Column(
                  spacing: AppDimensions.spacingSmall / 2,
                  children: [
                    CustomTextField(
                      model: CustomTextFieldModel(
                        controller: _bioController,
                        labelText: AppStrings.bio,
                        hintText: AppStrings.profileBioHint,
                        maxLines: AppDimensions.createPostCaptionMaxLines,
                        maxLength: AppDimensions.profileBioMaxLength,
                        enabled: state.status != EditProfileStatus.saving,
                        onChanged: _editProfileCubit.updateBio,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BlocBuilder<EditProfileCubit, EditProfileState>(
                        bloc: _editProfileCubit,
                        builder: (context, bioState) => CustomText(
                          model: CustomTextModel(
                            text:
                                '${bioState.bio.length}/${AppDimensions.profileBioMaxLength}',
                            fontSize: AppFontSize.compact,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profilePhoto(EditProfileState state) {
    final photoUrl = state.photoUrl?.trim() ?? _photoUrl?.trim();
    final isUploading = state.isUploadingPhoto;

    final avatar = Stack(
      alignment: Alignment.center,
      children: [
        photoUrl?.isNotEmpty == true
            ? CustomImage(
                model: CustomImageModel(
                  imageUrl: photoUrl,
                  width: AppDimensions.profileAvatarSize,
                  height: AppDimensions.profileAvatarSize,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.profileAvatarSize / 2,
                  ),
                ),
              )
            : DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: AppDimensions.profileAvatarSize,
                  height: AppDimensions.profileAvatarSize,
                  child: const CustomIcon(
                    model: CustomIconModel(
                      icon: CupertinoIcons.person_fill,
                      size: AppDimensions.profileAvatarSize / 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
        if (isUploading)
          Container(
            width: AppDimensions.profileAvatarSize,
            height: AppDimensions.profileAvatarSize,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CupertinoActivityIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppDimensions.spacingSmall,
      children: [
        Center(
          child: GestureDetector(
            onTap: isUploading || state.status == EditProfileStatus.saving
                ? null
                : _editProfileCubit.updateProfilePhoto,
            child: avatar,
          ),
        ),
        CupertinoButton(
          onPressed: isUploading || state.status == EditProfileStatus.saving
              ? null
              : _editProfileCubit.updateProfilePhoto,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          child: CustomText(
            model: CustomTextModel(
              text: isUploading
                  ? AppStrings.uploadingPhoto
                  : AppStrings.changeProfilePhoto,
              fontSize: AppFontSize.small,
              fontWeight: AppFontWeight.medium,
              style: TextStyle(
                color: isUploading
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
