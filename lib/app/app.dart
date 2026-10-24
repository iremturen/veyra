import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/constants/app_theme.dart';
import 'package:veyra/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:veyra/data/repositories/auth_repository_impl.dart';
import 'package:veyra/domain/repositories/auth_repository.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/pages/auth/auth_gate_page.dart';

class VeyraApp extends StatelessWidget {
  const VeyraApp({
    super.key,
    this.authRepository,
  });

  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    final repository = authRepository ??
        AuthRepositoryImpl(dataSource: FirebaseAuthDataSource());

    return RepositoryProvider<AuthRepository>.value(
      value: repository,
      child: BlocProvider<AuthCubit>(
        create: (context) =>
            AuthCubit(context.read<AuthRepository>())..restoreCurrentSession(),
        child: MaterialApp(
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
          home: const AuthGatePage(),
        ),
      ),
    );
  }
}
