/// Video preview widget for VibeEdit AI
/// Video player with overlay controls
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Video preview with overlay
class VideoPreview extends StatelessWidget {
  const VideoPreview({
    super.key,
    required this.currentTime,
    required this.isPlaying,
    required this.onPlayPause,
    this.thumbnailPath,
    this.resolution = '1080P',
  });

  final String currentTime;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final String? thumbnailPath;
  final String resolution;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cinematic gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A0A2E), // Deep purple
                    Color(0xFF0D0D0D), // Almost black
                    Color(0xFF0A1628), // Deep blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Icon(
                    Icons.movie_creation_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Vignette effect
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  radius: 1.2,
                ),
              ),
            ),

            // Play button overlay (when paused)
            if (!isPlaying)
              GestureDetector(
                onTap: onPlayPause,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacing20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.textPrimary,
                      size: 48,
                    ),
                  ),
                ),
              ),

            // Resolution badge (top right)
            Positioned(
              top: AppSizes.spacing12,
              right: AppSizes.spacing12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing8,
                  vertical: AppSizes.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  resolution,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            // Timecode overlay (bottom center)
            Positioned(
              bottom: AppSizes.spacing16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                    vertical: AppSizes.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(currentTime, style: AppTextStyles.timecode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
