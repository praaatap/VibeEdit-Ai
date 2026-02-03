/// AI Copilot FAB widget for VibeEdit AI
/// Floating button to access AI assistant
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// AI Copilot floating action button
class AICopilotFab extends StatelessWidget {
  const AICopilotFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI icon with sparkle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSizes.spacing8),

            // Text
            Text(
              AppStrings.askAiCopilot,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mic button for voice input
class VoiceMicButton extends StatelessWidget {
  const VoiceMicButton({
    super.key,
    required this.onTap,
    this.isListening = false,
  });

  final VoidCallback onTap;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: isListening
              ? LinearGradient(colors: [Colors.red, Colors.redAccent])
              : AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? Colors.red : AppColors.primary).withValues(
                alpha: 0.4,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop : Icons.mic,
          color: AppColors.textPrimary,
          size: AppSizes.iconMedium,
        ),
      ),
    );
  }
}
