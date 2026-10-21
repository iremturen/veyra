import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/constants/app_theme.dart';
import 'package:veyra/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:veyra/data/repositories/auth_repository_impl.dart';
import 'package:veyra/presentation/cubits/auth_cubit.dart';
import 'package:veyra/presentation/pages/email_verification_page.dart';
import 'package:veyra/presentation/pages/main_page.dart';
import 'package:veyra/presentation/pages/onboarding_page.dart';

class VeyraApp extends StatelessWidget {
  const VeyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => CupertinoTheme(
        data: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          barBackgroundColor: AppColors.background,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(
      AuthRepositoryImpl(dataSource: FirebaseAuthDataSource()),
    )..restoreCurrentSession();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: _authCubit,
      builder: (context, state) {
        if (state.status == AuthStatus.initial ||
            state.status == AuthStatus.loading) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
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
