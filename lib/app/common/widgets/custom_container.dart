import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../models/custom_container_model.dart';

class CustomContainer extends StatelessWidget {
  final CustomContainerModel model;

  const CustomContainer({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: model.width,
      height: model.height,
      padding: model.padding,
      margin: model.margin,
      alignment: model.alignment,
      decoration: BoxDecoration(
        color: model.color,
        borderRadius:
            model.borderRadius ??
            BorderRadius.circular(AppDimensions.borderRadius),
        border: model.border,
      ),
      child: model.child,
    );
  }
}
