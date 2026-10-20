import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/custom_icon_model.dart';
import '../models/custom_image_model.dart';
import 'custom_icon.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({required this.model, super.key});

  final CustomImageModel model;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: model.borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: model.width,
        height: model.height,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (model.imageUrl != null) {
      return Image.network(
        model.imageUrl!,
        fit: model.fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return _buildPlaceholder(
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: AppDimensions.customImageLoaderStrokeWidth,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    if (model.assetPath != null) {
      return Image.asset(
        model.assetPath!,
        fit: model.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({Widget? child}) {
    return ColoredBox(
      color: model.backgroundColor ?? AppColors.divider,
      child: Center(
        child:
            child ??
            CustomIcon(
              model: CustomIconModel(
                icon: Icons.image_outlined,
                size: model.iconSize,
                color: AppColors.textSecondary,
              ),
            ),
      ),
    );
  }
}
