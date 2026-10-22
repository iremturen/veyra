import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

class CustomImageModel {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final double? iconSize;

  const CustomImageModel({
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.iconSize = AppDimensions.customImagePlaceholderIconSize,
  }) : assert(
         imageUrl == null || assetPath == null,
         AppStrings.customImageSourceAssertion,
       );
}
