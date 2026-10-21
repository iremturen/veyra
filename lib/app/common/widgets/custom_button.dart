import 'package:flutter/cupertino.dart';

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
    final disabled =
        !model.isEnabled || model.isLoading || model.onPressed == null;
    final radius =
        model.borderRadius ?? BorderRadius.circular(AppDimensions.borderRadius);
    final foregroundColor = model.foregroundColor ?? CupertinoColors.white;

    return SizedBox(
      width: model.width,
      height: model.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: disabled
              ? (model.backgroundColor ?? AppColors.primary).withValues(
                  alpha: AppDimensions.buttonDisabledOpacity,
                )
              : (model.backgroundColor ?? AppColors.primary),
          borderRadius: radius.resolve(Directionality.of(context)),
          border: model.border == null
              ? null
              : Border.fromBorderSide(model.border!),
        ),
        child: CupertinoButton(
          onPressed: disabled ? null : model.onPressed,
          color: const Color(0x00000000),
          foregroundColor: foregroundColor,
          disabledColor: const Color(0x00000000),
          borderRadius: radius.resolve(Directionality.of(context)),
          padding: model.padding ?? EdgeInsets.zero,
          minimumSize: Size.zero,
          pressedOpacity: 0.75,
          child: model.isLoading
              ? SizedBox(
                  width: AppDimensions.buttonLoaderSize,
                  height: AppDimensions.buttonLoaderSize,
                  child: const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (model.icon != null)
                      CustomIcon(
                        model: CustomIconModel(
                          icon: model.icon!,
                          size: AppDimensions.buttonIconSize,
                          color: foregroundColor,
                        ),
                      ),
                    if (model.icon != null)
                      const SizedBox(width: AppDimensions.spacingSmall),
                    Flexible(
                      child: CustomText(
                        model: CustomTextModel(
                          text: model.text,
                          fontWeight: model.fontWeight,
                          style: TextStyle(color: foregroundColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
