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
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/cubits/auth/password_visibility_cubit.dart';
import 'package:veyra/presentation/pages/auth/email_verification_page.dart';
import 'package:veyra/presentation/pages/auth/register_page.dart';
import 'package:veyra/presentation/pages/main/main_page.dart';
import 'package:veyra/presentation/widgets/debug/crashlytics_debug_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (!AppValidators.isValidEmail(email)) {
      context.showSnackBar(AppStrings.emailRequired);
      return;
    }

    await context.read<AuthCubit>().sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordVisibilityCubit(),
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
            context.showSnackBar(AppStrings.resetEmailSent);
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
                                const _SignInHeader(),
                                _SignInEmailField(
                                  controller: _emailController,
                                ),
                                _SignInPasswordField(
                                  controller: _passwordController,
                                ),
                                _ForgotPasswordButton(
                                  onPressed: _resetPassword,
                                ),
                                _SignInSubmitButton(
                                  isLoading: authState.isLoading,
                                  onPressed: _submit,
                                ),
                                const _SignInFooter(),
                                const CrashlyticsDebugButton(),
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

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppDimensions.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
          model: CustomTextModel(
            text: AppStrings.welcomeBack,
            style: const TextStyle(color: AppColors.textPrimary),
            fontSize: AppFontSize.title,
            fontWeight: AppFontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
        CustomText(
          model: CustomTextModel(
            text: AppStrings.signInSubtitle,
            style: const TextStyle(color: AppColors.textSecondary),
            fontSize: AppFontSize.small,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SignInEmailField extends StatelessWidget {
  const _SignInEmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      model: CustomTextFieldModel(
        controller: controller,
        labelText: AppStrings.email,
        hintText: AppStrings.emailHint,
        keyboardType: TextInputType.emailAddress,
        prefixIcon: CupertinoIcons.mail,
        validator: AppValidators.validateEmail,
      ),
    );
  }
}

class _SignInPasswordField extends StatelessWidget {
  const _SignInPasswordField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordVisibilityCubit, PasswordVisibilityState>(
      buildWhen: (previous, current) =>
          previous.passwordVisible != current.passwordVisible,
      builder: (context, visibilityState) => CustomTextField(
        model: CustomTextFieldModel(
          controller: controller,
          labelText: AppStrings.password,
          hintText: AppStrings.passwordHint,
          obscureText: !visibilityState.passwordVisible,
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
          validator: AppValidators.validateSignInPassword,
        ),
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: const CustomText(
          model: CustomTextModel(
            text: AppStrings.forgotPassword,
            style: TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
            fontSize: AppFontSize.small,
          ),
        ),
      ),
    );
  }
}

class _SignInSubmitButton extends StatelessWidget {
  const _SignInSubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingExtraLarge),
      child: CustomButton(
        model: CustomButtonModel(
          text: AppStrings.signIn,
          onPressed: onPressed,
          width: double.infinity,
          height: AppDimensions.authSubmitButtonHeight,
          isLoading: isLoading,
          backgroundColor: AppColors.primary,
          foregroundColor: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }
}

class _SignInFooter extends StatelessWidget {
  const _SignInFooter();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSmall,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const CustomText(
          model: CustomTextModel(
            text: AppStrings.dontHaveAccount,
            style: TextStyle(color: AppColors.textSecondary),
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
          child: const CustomText(
            model: CustomTextModel(
              text: AppStrings.signUp,
              style: TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              fontSize: AppFontSize.small,
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
