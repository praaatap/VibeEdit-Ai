/// Card widget for VibeEdit AI
/// Opaque container with border and rounded corners
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A card widget with border and rounded corners
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge);

    Widget cardContent = ClipRRect(
      borderRadius: radius,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSizes.spacing16),
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: gradient,
          border: Border.all(
            color: borderColor ?? AppColors.cardBorder,
            width: 1,
          ),
          color: AppColors.cardBackground,
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}

/// A card with a glow effect
class GlowingGlassCard extends StatelessWidget {
  const GlowingGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge);
    final glow = glowColor ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: padding,
        borderRadius: radius,
        borderColor: glow.withValues(alpha: 0.5),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
