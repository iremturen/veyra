import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    required this.imageUrl,
    this.aspectRatio = AppDimensions.postImageAspectRatio,
    super.key,
  });

  final String imageUrl;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CustomImage(
        model: CustomImageModel(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          backgroundColor: AppColors.background,
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
