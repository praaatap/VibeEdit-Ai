/// Project detail screen for VibeEdit AI
/// Shows project info, clips, and actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../data/models/models.dart';

/// Project detail screen
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
    this.onEdit,
    this.onDelete,
  });

  final Project project;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with thumbnail
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie_outlined,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
              title: Text(project.name, style: AppTextStyles.titleMedium),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              PopupMenuButton<String>(
                color: AppColors.surface,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text('Rename', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text('Duplicate', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Project info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _buildStatsRow(),
                  const SizedBox(height: AppSizes.spacing24),

                  // Quick actions
                  _buildQuickActions(context),
                  const SizedBox(height: AppSizes.spacing24),

                  // Tracks section
                  Text('Tracks', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildTracksList(),
                  const SizedBox(height: AppSizes.spacing24),

                  // Export history
                  Text('Export History', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildExportHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            Icons.timer_outlined,
            project.formattedDuration,
            'Duration',
          ),
          _buildDividerVertical(),
          _buildStat(
            Icons.video_library_outlined,
            '${project.videoTracks.length}',
            'Video',
          ),
          _buildDividerVertical(),
          _buildStat(
            Icons.layers_outlined,
            '${project.tracks.length}',
            'Tracks',
          ),
          _buildDividerVertical(),
          _buildStat(
            Icons.aspect_ratio_outlined,
            _getAspectRatioLabel(),
            'Ratio',
          ),
        ],
      ),
    );
  }

  String _getAspectRatioLabel() {
    if ((project.aspectRatio - 9 / 16).abs() < 0.01) return '9:16';
    if ((project.aspectRatio - 16 / 9).abs() < 0.01) return '16:9';
    if ((project.aspectRatio - 1).abs() < 0.01) return '1:1';
    return '${(project.aspectRatio * 9).round()}:9';
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(width: 1, height: 50, color: AppColors.cardBorder);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.video_call_outlined,
            label: 'Add Clip',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.music_note_outlined,
            label: 'Add Music',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.text_fields_outlined,
            label: 'Add Text',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.smart_toy_outlined,
            label: 'AI Magic',
            onTap: () {},
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTracksList() {
    if (project.tracks.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: AppColors.cardBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                color: AppColors.textTertiary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No tracks yet',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Add your first clip',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: project.tracks.map((track) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTrackColor(track.type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTrackIcon(track.type),
                color: _getTrackColor(track.type),
                size: 20,
              ),
            ),
            title: Text(track.name, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              '${track.clips.length} clip${track.clips.length != 1 ? 's' : ''}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
          );
        }).toList(),
      ),
    );
  }

  Color _getTrackColor(TrackType type) {
    switch (type) {
      case TrackType.video:
        return AppColors.primary;
      case TrackType.audio:
        return AppColors.accent;
      case TrackType.text:
        return const Color(0xFF22C55E);
    }
  }

  IconData _getTrackIcon(TrackType type) {
    switch (type) {
      case TrackType.video:
        return Icons.videocam_rounded;
      case TrackType.audio:
        return Icons.audiotrack_rounded;
      case TrackType.text:
        return Icons.text_fields_rounded;
    }
  }

  Widget _buildExportHistory() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: project.outputPath != null
          ? _buildExportItem(
              'Exported Video',
              'Completed',
              Icons.check_circle,
              AppColors.success,
            )
          : Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No exports yet',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExportItem(
    String platform,
    String date,
    IconData statusIcon,
    Color statusColor,
  ) {
    return Row(
      children: [
        Icon(Icons.video_file_outlined, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(platform, style: AppTextStyles.bodyMedium),
              Text(
                date,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Icon(statusIcon, color: statusColor, size: 20),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.cardBorder),
                ),
                child: Text('Preview', style: AppTextStyles.labelLarge),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Continue Editing', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action button
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
