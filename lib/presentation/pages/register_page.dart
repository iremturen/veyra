import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_auth_rules.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_field_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/app/common/widgets/custom_text_field.dart';
import 'package:veyra/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:veyra/data/repositories/auth_repository_impl.dart';
import 'package:veyra/presentation/pages/email_verification_page.dart';
import 'package:veyra/presentation/pages/sign_in_page.dart';
import 'package:veyra/presentation/cubits/auth_cubit.dart';
import 'package:veyra/presentation/cubits/password_visibility_cubit.dart';

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
  final _authCubit = AuthCubit(
    AuthRepositoryImpl(dataSource: FirebaseAuthDataSource()),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authCubit.close();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await _authCubit.register(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => PasswordVisibilityCubit()),
      ],
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, authState) => CustomScaffold(
          model: CustomScaffoldModel(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, _) => SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.authFormMaxWidth,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: AppDimensions.spacingLarge,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CupertinoButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                child: const Icon(
                                  CupertinoIcons.back,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Column(
                              spacing: AppDimensions.spacingSmall,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  model: CustomTextModel(
                                    text: AppStrings.createAccount,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    fontSize: AppFontSize.title,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                                CustomText(
                                  model: CustomTextModel(
                                    text: AppStrings.signUpSubtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                    fontSize: AppFontSize.small,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              spacing: AppDimensions.spacingMedium,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomTextField(
                                  model: CustomTextFieldModel(
                                    controller: _emailController,
                                    labelText: AppStrings.email,
                                    hintText: AppStrings.emailHint,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: CupertinoIcons.mail,
                                    validator: _validateEmail,
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
                                          obscureText:
                                              !visibilityState.passwordVisible,
                                          prefixIcon: CupertinoIcons.lock,
                                          suffixIcon: CupertinoButton(
                                            onPressed: context
                                                .read<PasswordVisibilityCubit>()
                                                .togglePasswordVisibility,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            child: Icon(
                                              visibilityState.passwordVisible
                                                  ? CupertinoIcons.eye_slash
                                                  : CupertinoIcons.eye,
                                            ),
                                          ),
                                          validator: _validatePassword,
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
                                          labelText: AppStrings.confirmPassword,
                                          hintText:
                                              AppStrings.confirmPasswordHint,
                                          obscureText: !visibilityState
                                              .confirmPasswordVisible,
                                          prefixIcon: CupertinoIcons.lock,
                                          suffixIcon: CupertinoButton(
                                            onPressed: context
                                                .read<PasswordVisibilityCubit>()
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
                                          validator: _validateConfirmPassword,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                            CustomButton(
                              model: CustomButtonModel(
                                text: AppStrings.createAccount,
                                onPressed: _submit,
                                width: double.infinity,
                                height: AppDimensions.authSubmitButtonHeight,
                                isLoading: authState.isLoading,
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadius,
                                ),
                              ),
                            ),
                            Wrap(
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
                                          builder: (_) => const SignInPage(),
                                        ),
                                      ),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  child: CustomText(
                                    model: CustomTextModel(
                                      text: AppStrings.signIn,
                                      style: const TextStyle(
                                        color: AppColors.primary,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.emailRequired;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < AppAuthRules.minimumPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
