import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veyra/app/common/constants/app_font_family.dart';
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
    final googleFontStyle = GoogleFonts.getFont(
      model.fontFamily ?? AppFontFamily.body,
      textStyle: style,
      fontStyle: style?.fontStyle,
    );

    return Text(
      model.text,
      style: googleFontStyle,
      textAlign: model.textAlign,
      maxLines: model.maxLines,
      overflow: model.overflow,
    );
  }
}
