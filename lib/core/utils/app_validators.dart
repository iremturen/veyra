import 'package:veyra/app/common/constants/app_auth_rules.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

abstract final class AppValidators {
  AppValidators._();

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static bool isValidEmail(String? value) {
    final email = value?.trim() ?? '';
    return email.isNotEmpty && _emailRegExp.hasMatch(email);
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.emailRequired;
    if (!_emailRegExp.hasMatch(email)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  static String? validateSignInPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if ((value ?? '').length < AppAuthRules.minimumPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
