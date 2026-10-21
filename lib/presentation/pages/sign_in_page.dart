import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
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
import 'package:veyra/presentation/cubits/auth_cubit.dart';
import 'package:veyra/presentation/cubits/password_visibility_cubit.dart';
import 'package:veyra/presentation/pages/email_verification_page.dart';
import 'package:veyra/presentation/pages/crashlytics_test_page.dart';
import 'package:veyra/presentation/pages/main_page.dart';
import 'package:veyra/presentation/pages/register_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authCubit = AuthCubit(
    AuthRepositoryImpl(dataSource: FirebaseAuthDataSource()),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authCubit.close();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await _authCubit.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.emailRequired)));
      return;
    }

    await _authCubit.sendPasswordResetEmail(email: email);
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
          if (state.status == AuthStatus.success && state.user != null) {
            final Widget destination = state.user!.emailVerified
                ? const MainPage()
                : EmailVerificationPage(email: _emailController.text.trim());
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (_) => destination),
              (route) => false,
            );
          } else if (state.status == AuthStatus.passwordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.resetEmailSent)),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CupertinoButton(
                              onPressed: () => Navigator.of(context).maybePop(),
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
                                  text: AppStrings.welcomeBack,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  fontSize: AppFontSize.title,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                              CustomText(
                                model: CustomTextModel(
                                  text: AppStrings.signInSubtitle,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  fontSize: AppFontSize.small,
                                ),
                              ),
                            ],
                          ),
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
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? AppStrings.passwordRequired
                                        : null,
                                  ),
                                ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              onPressed: _resetPassword,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              child: CustomText(
                                model: CustomTextModel(
                                  text: AppStrings.forgotPassword,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                  fontSize: AppFontSize.small,
                                ),
                              ),
                            ),
                          ),
                          CustomButton(
                            model: CustomButtonModel(
                              text: AppStrings.signIn,
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
                                  text: AppStrings.dontHaveAccount,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  fontSize: AppFontSize.small,
                                ),
                              ),
                              CupertinoButton(
                                onPressed: () => Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                child: CustomText(
                                  model: CustomTextModel(
                                    text: AppStrings.signUp,
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
                          if (kDebugMode)
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => const CrashlyticsTestPage(),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.spacingSmall,
                                ),
                              ),
                              child: const Text(AppStrings.crashlyticsTest),
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
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.emailRequired;
    if (!_isValidEmail(email)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}
