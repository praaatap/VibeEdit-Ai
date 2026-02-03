/// Icon chip widget for VibeEdit AI
/// Chip buttons with icons for quick actions
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// A chip with an icon and label
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.borderColor,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.2)
        : (backgroundColor ?? AppColors.surfaceLight);
    final fgColor = isSelected
        ? AppColors.primary
        : (iconColor ?? AppColors.textSecondary);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: AppSizes.spacing8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            border: Border.all(
              color:
                  borderColor ??
                  (isSelected ? AppColors.primary : Colors.transparent),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSmall, color: fgColor),
              const SizedBox(width: AppSizes.spacing8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: textColor ?? fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of quick action chips
class QuickActionChips extends StatelessWidget {
  const QuickActionChips({super.key, required this.actions, this.onActionTap});

  final List<QuickAction> actions;
  final void Function(String actionKey)? onActionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacing8),
            child: IconChip(
              icon: action.icon,
              label: action.label,
              onTap: () => onActionTap?.call(action.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Quick action data model
class QuickAction {
  const QuickAction({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}
