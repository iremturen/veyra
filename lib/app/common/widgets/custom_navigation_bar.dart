import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/custom_icon_model.dart';
import '../models/custom_navigation_bar_model.dart';
import 'custom_icon.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({required this.model, super.key});

  final CustomNavigationBarModel model;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLens(
      style: const LiquidGlassStyle(
        shape: LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: AppDimensions.navigationBarHeight / 2,
        ),
        color: Color(0xB8F7E9F2),
        blur: 20,
        refractionIndex: 1.04,
        refractionWidth: 18,
      ),
      child: SizedBox(
        height: AppDimensions.navigationBarHeight,
        child: Row(
          children: [
            for (var index = 0; index < 2; index++)
              Expanded(child: _destination(index)),
            Expanded(
              child: Center(
                child: _CreateActionButton(onPressed: model.onCreatePressed),
              ),
            ),
            for (var index = 2; index < model.items.length; index++)
              Expanded(child: _destination(index)),
          ],
        ),
      ),
    );
  }

  Widget _destination(int index) {
    final item = model.items[index];
    final selected = model.selectedIndex == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: CupertinoButton(
        onPressed: () => model.onDestinationSelected(index),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        pressedOpacity: 0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSmall / 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIcon(
                model: CustomIconModel(
                  icon: selected ? item.selectedIcon ?? item.icon : item.icon,
                  size: AppDimensions.navigationItemIconSize,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateActionButton extends StatefulWidget {
  const _CreateActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CreateActionButton> createState() => _CreateActionButtonState();
}

class _CreateActionButtonState extends State<_CreateActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: AppDimensions.navigationCreateGlowDurationMs,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, AppDimensions.navigationCreateButtonVerticalOffset),
      child: SizedBox(
        width: AppDimensions.navigationCreateGlowSize,
        height: AppDimensions.navigationCreateGlowSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0),
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.28, 0.5, 0.72, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: AppDimensions.spacingSmall,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              builder: (context, child) => Transform.rotate(
                angle: _glowController.value * 6.283185307179586,
                child: child,
              ),
            ),
            CupertinoButton(
              onPressed: widget.onPressed,
              color: AppColors.primary,
              foregroundColor: CupertinoColors.white,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              borderRadius: BorderRadius.circular(
                AppDimensions.navigationCreateButtonSize / 2,
              ),
              pressedOpacity: 0.75,
              child: const SizedBox(
                width: AppDimensions.navigationCreateButtonSize,
                height: AppDimensions.navigationCreateButtonSize,
                child: Center(
                  child: CustomIcon(
                    model: CustomIconModel(
                      icon: CupertinoIcons.add,
                      size: AppDimensions.buttonIconSize + 4,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
