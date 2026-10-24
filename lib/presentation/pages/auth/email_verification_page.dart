import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_button_model.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_button.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/core/extensions/snack_bar_extension.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/pages/auth/sign_in_page.dart';
import 'package:veyra/presentation/pages/main/main_page.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.verificationEmailSent:
            context.showSnackBar(AppStrings.verificationEmailSent);
            break;
          case AuthStatus.emailVerified:
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (_) => const MainPage()),
              (route) => false,
            );
            break;
          case AuthStatus.emailNotVerified:
            context.showSnackBar(AppStrings.emailNotVerified);
            break;
          case AuthStatus.failure:
            context.showErrorSnackBar(state.message ?? '');
            break;
          default:
            break;
        }
      },
      builder: (context, authState) => CustomScaffold(
        model: CustomScaffoldModel(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.authFormMaxWidth,
                  ),
                  child: Column(
                    spacing: AppDimensions.spacingLarge,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomIcon(
                        model: CustomIconModel(
                          icon: CupertinoIcons.envelope_badge,
                          size: AppDimensions.emailVerificationIconSize,
                          color: AppColors.primary,
                        ),
                      ),
                      CustomText(
                        model: CustomTextModel(
                          text: AppStrings.verifyYourEmail,
                          style: const TextStyle(color: AppColors.textPrimary),
                          fontSize: AppFontSize.title,
                          fontWeight: AppFontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CustomText(
                        model: CustomTextModel(
                          text:
                              '${AppStrings.verificationInstructions}\n\n$email',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          fontSize: AppFontSize.small,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CustomButton(
                        model: CustomButtonModel(
                          text: AppStrings.sendVerificationEmail,
                          onPressed: () =>
                              context.read<AuthCubit>().sendVerificationEmail(),
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
                      CustomButton(
                        model: CustomButtonModel(
                          text: AppStrings.checkVerification,
                          onPressed: authState.isLoading
                              ? null
                              : () => context
                                  .read<AuthCubit>()
                                  .checkEmailVerified(),
                          width: double.infinity,
                          height: AppDimensions.authSubmitButtonHeight,
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.primary,
                          border: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          CupertinoPageRoute<void>(
                            builder: (_) => const SignInPage(),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        child: const CustomText(
                          model: CustomTextModel(
                            text: AppStrings.alreadyHaveAccount,
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
      ),
    );
  }
}
