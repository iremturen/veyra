import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/custom_button_model.dart';
import '../models/custom_icon_model.dart';
import '../models/custom_text_model.dart';
import 'custom_icon.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final CustomButtonModel model;

  const CustomButton({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        !model.isEnabled || model.isLoading || model.onPressed == null;

    return SizedBox(
      width: model.width,
      height: model.height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : model.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: model.backgroundColor ?? AppColors.primary,
          foregroundColor: model.foregroundColor ?? Colors.white,
          disabledBackgroundColor: (model.backgroundColor ?? AppColors.primary)
              .withValues(alpha: AppDimensions.buttonDisabledOpacity),
          shape: RoundedRectangleBorder(
            borderRadius: model.borderRadius ??
                BorderRadius.circular(AppDimensions.buttonBorderRadius),
            side: model.border ?? BorderSide.none,
          ),
          padding: model.padding,
        ),
        child: model.isLoading
            ? SizedBox(
                width: AppDimensions.buttonLoaderSize,
                height: AppDimensions.buttonLoaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.buttonLoaderStrokeWidth,
                  color: model.foregroundColor ?? Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (model.icon != null) ...[
                    CustomIcon(
                      model: CustomIconModel(
                        icon: model.icon!,
                        size: AppDimensions.buttonIconSize,
                      ),
                    ),
                  ],
                  Flexible(
                    child: CustomText(
                      model: CustomTextModel(
                        text: model.text,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
