import 'package:flutter/cupertino.dart';

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
    final prefixChildren = <Widget>[];
    if (model.prefixIcon != null) {
      prefixChildren.add(
        CustomIcon(
          model: CustomIconModel(
            icon: model.prefixIcon!,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    if (model.labelText != null) {
      if (prefixChildren.isNotEmpty) {
        prefixChildren.add(const SizedBox(width: AppDimensions.spacingSmall));
      }
      prefixChildren.add(
        Text(
          model.labelText!,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      );
    }

    return FormField<String>(
      initialValue: model.controller?.text ?? '',
      validator: model.validator,
      builder: (field) {
        final hasError = field.errorText != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.divider,
                ),
              ),
              child: CupertinoTextField(
                controller: model.controller,
                keyboardType: model.keyboardType,
                obscureText: model.obscureText,
                enabled: model.enabled,
                readOnly: model.readOnly,
                maxLines: model.obscureText ? 1 : model.maxLines,
                maxLength: model.maxLength,
                onChanged: (value) {
                  field.didChange(value);
                  model.onChanged?.call(value);
                },
                onSubmitted: model.onSubmitted,
                prefix: prefixChildren.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.spacingMedium,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: prefixChildren,
                        ),
                      ),
                suffix: model.suffixIcon == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(
                          right: AppDimensions.spacingSmall,
                        ),
                        child: model.suffixIcon,
                      ),
                placeholder: model.hintText,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMedium,
                  vertical: AppDimensions.spacingMedium,
                ),
                cursorColor: AppColors.primary,
                autocorrect: false,
                enableSuggestions: !model.obscureText,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.spacingMedium,
                  top: AppDimensions.spacingSmall / 2,
                ),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
