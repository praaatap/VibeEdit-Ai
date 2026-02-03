/// Project card widget for VibeEdit AI
/// Shows a project thumbnail in the recent projects grid
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart' hide Clip;
import '../../../shared/widgets/widgets.dart';

/// Project card showing thumbnail and metadata
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail or placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.surfaceLight, AppColors.surface],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: project.thumbnailPath != null
                        ? Image.asset(project.thumbnailPath!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: AppSizes.iconXLarge,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),

                  // Play button overlay
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.textPrimary,
                        size: AppSizes.iconLarge,
                      ),
                    ),
                  ),

                  // Duration badge
                  Positioned(
                    right: AppSizes.spacing8,
                    bottom: AppSizes.spacing8,
                    child: DurationBadge(duration: project.duration),
                  ),

                  // Draft badge
                  if (project.isDraft)
                    Positioned(
                      left: AppSizes.spacing8,
                      top: AppSizes.spacing8,
                      child: StatusBadge(
                        label: AppStrings.draft,
                        backgroundColor: AppColors.warning,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    '${AppStrings.editedAgo} ${project.editedAgo}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
