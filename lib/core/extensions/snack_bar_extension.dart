import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';

extension SnackBarBuildContextExtension on BuildContext {
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBarMessage(
      message,
      isError: isError,
      duration: duration,
      action: action,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      message,
      isError: true,
      duration: duration,
      action: action,
    );
  }
}

extension SnackBarMessengerExtension on ScaffoldMessengerState {
  void showSnackBarMessage(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        content: CustomText(
          model: CustomTextModel(
            text: message,
            style: TextStyle(color: textColor ?? Colors.white),
            fontSize: AppFontSize.small,
          ),
        ),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor ?? (isError ? AppColors.error : null),
      ),
    );
  }
}
