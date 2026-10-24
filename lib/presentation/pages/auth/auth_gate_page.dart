import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/pages/auth/email_verification_page.dart';
import 'package:veyra/presentation/pages/main/main_page.dart';
import 'package:veyra/presentation/pages/onboarding/onboarding_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial ||
            state.status == AuthStatus.loading) {
          return const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(
                radius: AppDimensions.activityIndicatorRadius,
              ),
            ),
          );
        }

        if (state.status == AuthStatus.sessionRestored) {
          return const MainPage();
        }

        if (state.status == AuthStatus.emailNotVerified &&
            state.user?.email != null) {
          return EmailVerificationPage(email: state.user!.email!);
        }

        return const OnboardingPage();
      },
    );
  }
}
