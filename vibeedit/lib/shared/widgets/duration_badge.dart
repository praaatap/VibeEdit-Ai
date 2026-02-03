/// Duration badge widget for VibeEdit AI
/// Shows video duration overlay on thumbnails
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A badge showing video duration
class DurationBadge extends StatelessWidget {
  const DurationBadge({
    super.key,
    required this.duration,
    this.alignment = Alignment.bottomRight,
  });

  final Duration duration;
  final Alignment alignment;

  String get _formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        _formattedDuration,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

/// A status badge (DRAFT, PROCESSING, etc.)
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.warning,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        label,
        style: AppTextStyles.tag.copyWith(color: color ?? Colors.black),
      ),
    );
  }
}

/// An AI powered tag
class AIPoweredTag extends StatelessWidget {
  const AIPoweredTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        'AI POWERED',
        style: AppTextStyles.tag.copyWith(color: Colors.white),
      ),
    );
  }
}

/// A "NEW" tag
class NewTag extends StatelessWidget {
  const NewTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        'NEW',
        style: AppTextStyles.tag.copyWith(color: Colors.white),
      ),
    );
  }
}
