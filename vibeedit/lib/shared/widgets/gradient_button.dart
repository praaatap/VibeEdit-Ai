/// Gradient button widget for VibeEdit AI
/// Buttons with gradient backgrounds and modern styling
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A button with gradient background
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium);

    return Container(
      width: width,
      height: height ?? AppSizes.buttonMedium,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? (gradient ?? AppColors.primaryGradient)
            : LinearGradient(
                colors: [AppColors.surfaceLight, AppColors.surfaceLight],
              ),
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: radius,
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// An icon button with a circular gradient background
class GradientIconButton extends StatelessWidget {
  const GradientIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.gradient,
    this.size = 48,
    this.iconSize = 24,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double size;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// An outlined button with rounded corners
class OutlinedGradientButton extends StatelessWidget {
  const OutlinedGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? borderColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium);

    return Container(
      width: width,
      height: height ?? AppSizes.buttonMedium,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(alignment: Alignment.center, child: child),
        ),
      ),
    );
  }
}
