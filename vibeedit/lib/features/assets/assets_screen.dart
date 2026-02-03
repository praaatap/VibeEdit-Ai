/// Assets screen for VibeEdit AI
/// Media library management
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// Assets screen
class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(AppStrings.assets, style: AppTextStyles.titleLarge),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'Your Media Library',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Import videos, images, and audio files',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
