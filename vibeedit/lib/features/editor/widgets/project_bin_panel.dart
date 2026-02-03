/// Project Bin panel showing media items (stubbed)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

class ProjectBinPanel extends StatelessWidget {
  const ProjectBinPanel({super.key, required this.project, this.onTapClip});

  final Project project;
  final void Function(String clipId)? onTapClip;

  @override
  Widget build(BuildContext context) {
    final clips = project.videoTracks
        .expand((t) => t.clips)
        .toList(growable: false);

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.all(AppSizes.spacing12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.panelBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_rounded, size: 16),
                const SizedBox(width: 8),
                Text('Project: ${project.name}', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppSizes.spacing12),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: clips.length,
              itemBuilder: (context, i) {
                final clip = clips[i];
                return GestureDetector(
                  onTap: () => onTapClip?.call(clip.id),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: AppColors.panelBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.movie_rounded, color: AppColors.textTertiary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Untitled Clip",
                          style: AppTextStyles.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
