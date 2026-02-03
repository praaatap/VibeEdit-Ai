/// Premium card widgets for VibeEdit AI
/// Modern solid cards with gradients, shadows, and animations
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A premium solid card with subtle gradient and shadow
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 8,
    this.onTap,
    this.animate = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation;
  final VoidCallback? onTap;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient,
        color: backgroundColor ?? AppColors.cardBackground,
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: elevation,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation * 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: AppColors.primary.withValues(alpha: 0.1),
            highlightColor: AppColors.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSizes.spacing16),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (animate) {
      return card
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 300.ms);
    }

    return card;
  }
}

/// A premium card with neon glow effect
class NeonGlowCard extends StatefulWidget {
  const NeonGlowCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.borderRadius,
    this.onTap,
    this.isActive = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  State<NeonGlowCard> createState() => _NeonGlowCardState();
}

class _NeonGlowCardState extends State<NeonGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonGlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge);
    final glowColor = widget.glowColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glowIntensity = widget.isActive
              ? _glowAnimation.value
              : (_isHovered ? 0.4 : 0.2);

          return Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowIntensity),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: glowColor.withValues(alpha: glowIntensity * 0.5),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: child,
          );
        },
        child: PremiumCard(
          padding: widget.padding,
          borderRadius: radius,
          borderColor: glowColor.withValues(alpha: 0.5),
          onTap: widget.onTap,
          animate: false,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Gradient accent card for CTAs and important actions
class GradientAccentCard extends StatelessWidget {
  const GradientAccentCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge);

    return Container(
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: gradient ?? AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppSizes.spacing16),
                child: child,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }
}
