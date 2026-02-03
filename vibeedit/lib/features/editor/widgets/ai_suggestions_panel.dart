/// AI Suggestions Panel for VibeEdit AI
/// Shows smart suggestions (UI stub)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

class AISuggestionsPanel extends StatelessWidget {
  const AISuggestionsPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final suggestions = <String>[
      'Add crossfade between Clip 2 and 3',
      'Stabilize shaky footage at 00:12-00:18',
      'Boost dialog volume by +3dB',
      'Apply Cinematic color grade',
      'Generate B-roll based on script',
    ];

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              itemBuilder: (context, i) => _SuggestionTile(text: suggestions[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: suggestions.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.neonOrange),
          const SizedBox(width: AppSizes.spacing8),
          Text('AI Suggestions', style: AppTextStyles.titleMedium),
          const Spacer(),
          _aiBadge(AppColors.neonOrange),
          const SizedBox(width: AppSizes.spacing8),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _aiBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: color),
          const SizedBox(width: 4),
          Text('AI', style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high_rounded, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
          TextButton(
            onPressed: () {},
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
