/// Playback controls widget for VibeEdit AI
/// Play/pause and skip controls
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Playback controls bar
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.currentTime,
    required this.totalTime,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipBack,
    required this.onSkipForward,
  });

  final String currentTime;
  final String totalTime;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacing12,
        horizontal: AppSizes.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.panelBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current time
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing8,
              vertical: AppSizes.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              currentTime,
              style: AppTextStyles.timecode.copyWith(
                color: AppColors.primary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: AppSizes.spacing16),

          // Skip back
          _ControlButton(icon: Icons.skip_previous_rounded, onTap: onSkipBack),

          const SizedBox(width: AppSizes.spacing8),

          // Frame back
          _ControlButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: onSkipBack,
            size: 32,
          ),

          const SizedBox(width: AppSizes.spacing12),

          // Play/Pause - main button (solid color, no gradient)
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.textPrimary,
                size: 32,
              ),
            ),
          ),

          const SizedBox(width: AppSizes.spacing12),

          // Frame forward
          _ControlButton(
            icon: Icons.keyboard_arrow_right_rounded,
            onTap: onSkipForward,
            size: 32,
          ),

          const SizedBox(width: AppSizes.spacing8),

          // Skip forward
          _ControlButton(icon: Icons.skip_next_rounded, onTap: onSkipForward),

          const SizedBox(width: AppSizes.spacing16),

          // Total time
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing8,
              vertical: AppSizes.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              totalTime,
              style: AppTextStyles.timecode.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Control button widget
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.panelBorder, width: 1),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: size * 0.5),
      ),
    );
  }
}
