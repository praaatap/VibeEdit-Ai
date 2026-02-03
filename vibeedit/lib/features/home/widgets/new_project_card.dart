/// New project card widget for VibeEdit AI
/// The main "Start Creating" card on home screen
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/widgets/widgets.dart';

/// New project card with AI tags
class NewProjectCard extends StatelessWidget {
  const NewProjectCard({super.key, required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Row(
            children: const [
              NewTag(),
              SizedBox(width: AppSizes.spacing8),
              AIPoweredTag(),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),

          // Title
          Text(AppStrings.newProject, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.spacing8),

          // Description
          Text(
            AppStrings.newProjectDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing20),

          // Create button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: onCreatePressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: AppSizes.iconMedium),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(AppStrings.create, style: AppTextStyles.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
