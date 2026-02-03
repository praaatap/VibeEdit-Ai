/// Loading shimmer widget for VibeEdit AI
/// Shimmer loading placeholder effects
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A shimmer loading placeholder
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key, this.width, this.height, this.borderRadius});

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium),
          ),
        )
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        );
  }
}

/// A shimmer placeholder for project cards
class ProjectCardShimmer extends StatelessWidget {
  const ProjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.projectCardHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: LoadingShimmer(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLarge),
                topRight: Radius.circular(AppSizes.radiusLarge),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(width: 120, height: 16),
                const SizedBox(height: AppSizes.spacing8),
                LoadingShimmer(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A shimmer placeholder for list items
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
      child: Row(
        children: [
          LoadingShimmer(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(width: 150, height: 16),
                const SizedBox(height: AppSizes.spacing8),
                LoadingShimmer(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
