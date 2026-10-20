import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/presentation/pages/onboarding_page.dart';

class VeyraApp extends StatelessWidget {
  const VeyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      home: const OnboardingPage(),
    );
  }
}