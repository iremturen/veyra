import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/models/custom_container_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_container.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/data/services/firebase_remote_config_service.dart';

class ExploreBanner extends StatelessWidget {
  const ExploreBanner({required this.config, super.key});

  final ExploreBannerConfig config;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.borderRadius);

    return CustomContainer(
      model: CustomContainerModel(
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: AspectRatio(
            aspectRatio: AppDimensions.exploreBannerAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomImage(
                  model: CustomImageModel(
                    imageUrl: config.imageUrl,
                    backgroundColor: AppColors.secondarySoft,
                    borderRadius: radius,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: AppColors.exploreBannerGradientColors,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          model: CustomTextModel(
                            text: config.title,
                            fontSize: AppFontSize.medium,
                            fontWeight: AppFontWeight.bold,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSmall),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadius,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSmall,
                            vertical: AppDimensions.spacingSmall / 2,
                          ),
                          child: CustomText(
                            model: CustomTextModel(
                              text: config.number.toString(),
                              fontSize: AppFontSize.small,
                              fontWeight: AppFontWeight.bold,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
