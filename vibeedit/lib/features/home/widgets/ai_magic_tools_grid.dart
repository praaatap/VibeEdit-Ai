/// AI Magic Tools grid widget for VibeEdit AI
/// Shows the 4 AI tool cards on home screen
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/widgets/widgets.dart';

/// AI tool data model
class AITool {
  const AITool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
}

/// Predefined AI tools
class AITools {
  static const List<AITool> all = [
    AITool(
      id: 'auto_cut',
      name: AppStrings.autoCut,
      description: AppStrings.autoCutDesc,
      icon: Icons.content_cut,
      color: AppColors.primary,
    ),
    AITool(
      id: 'ai_enhance',
      name: AppStrings.aiEnhance,
      description: AppStrings.aiEnhanceDesc,
      icon: Icons.auto_awesome,
      color: AppColors.accent,
    ),
    AITool(
      id: 'smart_remove',
      name: AppStrings.smartRemove,
      description: AppStrings.smartRemoveDesc,
      icon: Icons.auto_fix_high,
      color: Color(0xFFEC4899), // Pink
    ),
    AITool(
      id: 'auto_captions',
      name: AppStrings.autoCaptions,
      description: AppStrings.autoCaptionsDesc,
      icon: Icons.closed_caption,
      color: AppColors.primary,
    ),
  ];
}

/// AI Magic Tools grid
class AIMagicToolsGrid extends StatelessWidget {
  const AIMagicToolsGrid({super.key, this.onToolTap, this.onViewAllTap});

  final void Function(AITool tool)? onToolTap;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.textPrimary,
                    size: AppSizes.iconMedium,
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    AppStrings.aiMagicTools,
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAllTap,
                child: Text(
                  AppStrings.viewAll,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing12),

        // Tools grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.spacing12,
            mainAxisSpacing: AppSizes.spacing12,
            childAspectRatio: 1.6,
          ),
          itemCount: AITools.all.length,
          itemBuilder: (context, index) {
            final tool = AITools.all[index];
            return _AIToolCard(tool: tool, onTap: () => onToolTap?.call(tool));
          },
        ),
      ],
    );
  }
}

class _AIToolCard extends StatelessWidget {
  const _AIToolCard({required this.tool, required this.onTap});

  final AITool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing8),
            decoration: BoxDecoration(
              color: tool.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Icon(
              tool.icon,
              color: tool.color,
              size: AppSizes.iconMedium,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),

          // Name
          Text(tool.name, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSizes.spacing2),

          // Description
          Text(
            tool.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
