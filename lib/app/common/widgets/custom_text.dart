import 'package:flutter/material.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';

class CustomText extends StatelessWidget {
  final CustomTextModel model;

  const CustomText({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = model.fontSize == null && model.fontWeight == null
        ? model.style
        : (model.style ?? const TextStyle()).copyWith(
            fontSize: model.fontSize?.value,
            fontWeight: model.fontWeight?.value,
          );

    return Text(
      model.text,
      style: style,
      textAlign: model.textAlign,
      maxLines: model.maxLines,
      overflow: model.overflow,
    );
  }
}
