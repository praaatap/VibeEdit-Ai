/// Templates screen for VibeEdit AI
/// Browse video templates
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// Templates screen
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(AppStrings.templates, style: AppTextStyles.titleLarge),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'Templates Coming Soon',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Beautiful video templates will be available here',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
