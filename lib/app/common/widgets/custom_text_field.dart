import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/custom_icon_model.dart';
import '../models/custom_text_field_model.dart';
import 'custom_icon.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({required this.model, super.key});

  final CustomTextFieldModel model;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: model.controller,
      keyboardType: model.keyboardType,
      obscureText: model.obscureText,
      enabled: model.enabled,
      readOnly: model.readOnly,
      maxLines: model.obscureText
          ? AppDimensions.textFieldMaxLines
          : model.maxLines,
      maxLength: model.maxLength,
      validator: model.validator,
      onChanged: model.onChanged,
      onFieldSubmitted: model.onSubmitted,
      decoration: InputDecoration(
        hintText: model.hintText,
        labelText: model.labelText,
        prefixIcon: model.prefixIcon == null
            ? null
            : CustomIcon(model: CustomIconModel(icon: model.prefixIcon!)),
        suffixIcon: model.suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.textFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.textFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.textFieldBorderRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.textFieldFocusedBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.textFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
