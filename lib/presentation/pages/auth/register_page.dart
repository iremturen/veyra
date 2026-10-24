import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_field_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/app/common/widgets/custom_text_field.dart';
import 'package:veyra/core/extensions/snack_bar_extension.dart';
import 'package:veyra/core/utils/app_validators.dart';
import 'package:veyra/presentation/pages/auth/email_verification_page.dart';
import 'package:veyra/presentation/pages/auth/sign_in_page.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/cubits/auth/password_visibility_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordVisibilityCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute<void>(
                builder: (_) =>
                    EmailVerificationPage(email: _emailController.text.trim()),
              ),
            );
          } else if (state.status == AuthStatus.failure) {
            context.showErrorSnackBar(state.message ?? '');
          }
        },
        builder: (context, authState) => CustomScaffold(
          model: CustomScaffoldModel(
            appBar: CustomAppBar(
              model: CustomAppBarModel(
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
                showBottomBorder: false,
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingExtraLarge,
                  ),
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight >
                                AppDimensions.spacingExtraLarge * 2
                            ? constraints.maxHeight -
                                  AppDimensions.spacingExtraLarge * 2
                            : 0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppDimensions.authFormMaxWidth,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              spacing: AppDimensions.spacingMedium,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  spacing: AppDimensions.spacingSmall,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      model: CustomTextModel(
                                        text: AppStrings.createAccount,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                        fontSize: AppFontSize.title,
                                        fontWeight: AppFontWeight.bold,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    CustomText(
                                      model: CustomTextModel(
                                        text: AppStrings.signUpSubtitle,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        fontSize: AppFontSize.small,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  spacing: AppDimensions.spacingMedium,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    CustomTextField(
                                      model: CustomTextFieldModel(
                                        controller: _emailController,
                                        labelText: AppStrings.email,
                                        hintText: AppStrings.emailHint,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        prefixIcon: CupertinoIcons.mail,
                                        validator: AppValidators.validateEmail,
                                      ),
                                    ),
                                    BlocBuilder<
                                      PasswordVisibilityCubit,
                                      PasswordVisibilityState
                                    >(
                                      builder: (context, visibilityState) =>
                                          CustomTextField(
                                            model: CustomTextFieldModel(
                                              controller: _passwordController,
                                              labelText: AppStrings.password,
                                              hintText: AppStrings.passwordHint,
                                              obscureText: !visibilityState
                                                  .passwordVisible,
                                              prefixIcon: CupertinoIcons.lock,
                                              suffixIcon: CupertinoButton(
                                                onPressed: context
                                                    .read<
                                                      PasswordVisibilityCubit
                                                    >()
                                                    .togglePasswordVisibility,
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                child: Icon(
                                                  visibilityState
                                                          .passwordVisible
                                                      ? CupertinoIcons.eye_slash
                                                      : CupertinoIcons.eye,
                                                ),
                                              ),
                                              validator:
                                                  AppValidators.validatePassword,
                                            ),
                                          ),
                                    ),
                                    BlocBuilder<
                                      PasswordVisibilityCubit,
                                      PasswordVisibilityState
                                    >(
                                      builder: (context, visibilityState) =>
                                          CustomTextField(
                                            model: CustomTextFieldModel(
                                              controller:
                                                  _confirmPasswordController,
                                              labelText:
                                                  AppStrings.confirmPassword,
                                              hintText: AppStrings
                                                  .confirmPasswordHint,
                                              obscureText: !visibilityState
                                                  .confirmPasswordVisible,
                                              prefixIcon: CupertinoIcons.lock,
                                              suffixIcon: CupertinoButton(
                                                onPressed: context
                                                    .read<
                                                      PasswordVisibilityCubit
                                                    >()
                                                    .toggleConfirmPasswordVisibility,
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                child: Icon(
                                                  visibilityState
                                                          .confirmPasswordVisible
                                                      ? CupertinoIcons.eye_slash
                                                      : CupertinoIcons.eye,
                                                ),
                                              ),
                                              validator: (value) =>
                                                  AppValidators.validateConfirmPassword(
                                                    value,
                                                    _passwordController.text,
                                                  ),
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppDimensions.spacingExtraLarge,
                                  ),
                                  child: CustomButton(
                                    model: CustomButtonModel(
                                      text: AppStrings.createAccount,
                                      onPressed: _submit,
                                      width: double.infinity,
                                      height:
                                          AppDimensions.authSubmitButtonHeight,
                                      isLoading: authState.isLoading,
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.borderRadius,
                                      ),
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: AppDimensions.spacingSmall,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    CustomText(
                                      model: CustomTextModel(
                                        text: AppStrings.alreadyHaveAccount,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        fontSize: AppFontSize.small,
                                      ),
                                    ),
                                    CupertinoButton(
                                      onPressed: () =>
                                          Navigator.of(context).pushReplacement(
                                            CupertinoPageRoute<void>(
                                              builder: (_) =>
                                                  const SignInPage(),
                                            ),
                                          ),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      child: CustomText(
                                        model: CustomTextModel(
                                          text: AppStrings.signIn,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          fontSize: AppFontSize.small,
                                          fontWeight: AppFontWeight.bold,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
