/// Export screen for VibeEdit AI
/// Professional export with platform presets and quality options
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../data/services/api_service.dart';

/// Platform preset model
class PlatformPreset {
  const PlatformPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.resolution,
    required this.description,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final IconData icon;
  final String resolution;
  final String description;
  final Color color;
}

/// Available platform presets
class Platforms {
  static const instagramReels = PlatformPreset(
    id: 'instagram_reels',
    name: 'Instagram Reels',
    icon: Icons.ondemand_video_rounded,
    resolution: '1080×1920',
    description: '9:16 • Max 90s',
    color: Color(0xFFE1306C),
  );

  static const youtubeShorts = PlatformPreset(
    id: 'youtube_shorts',
    name: 'YouTube Shorts',
    icon: Icons.smart_display_rounded,
    resolution: '1080×1920',
    description: '9:16 • Max 60s',
    color: Color(0xFFFF0000),
  );

  static const tiktok = PlatformPreset(
    id: 'tiktok',
    name: 'TikTok',
    icon: Icons.music_note_rounded,
    resolution: '1080×1920',
    description: '9:16 • Max 3min',
    color: Color(0xFF00F2EA),
  );

  static const youtube = PlatformPreset(
    id: 'youtube',
    name: 'YouTube',
    icon: Icons.play_circle_filled_rounded,
    resolution: '1920×1080',
    description: '16:9 • No limit',
    color: Color(0xFFFF0000),
  );

  static const youtube4k = PlatformPreset(
    id: 'youtube_4k',
    name: 'YouTube 4K',
    icon: Icons.hd_rounded,
    resolution: '3840×2160',
    description: '16:9 • Ultra HD',
    color: Color(0xFFCC0000),
  );

  static const twitter = PlatformPreset(
    id: 'twitter',
    name: 'Twitter/X',
    icon: Icons.tag_rounded,
    resolution: '1280×720',
    description: '16:9 • Max 140s',
    color: Color(0xFF1DA1F2),
  );

  static const linkedin = PlatformPreset(
    id: 'linkedin',
    name: 'LinkedIn',
    icon: Icons.business_center_rounded,
    resolution: '1920×1080',
    description: '16:9 • Max 10min',
    color: Color(0xFF0A66C2),
  );

  static const instagramFeed = PlatformPreset(
    id: 'instagram_feed',
    name: 'Instagram Feed',
    icon: Icons.grid_on_rounded,
    resolution: '1080×1080',
    description: '1:1 • Max 60s',
    color: Color(0xFFE1306C),
  );

  static const List<PlatformPreset> all = [
    instagramReels,
    youtubeShorts,
    tiktok,
    youtube,
    youtube4k,
    twitter,
    linkedin,
    instagramFeed,
  ];
}

/// Quality preset
class QualityPreset {
  const QualityPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}

/// Available quality presets
class Qualities {
  static const low = QualityPreset(
    id: 'low',
    name: 'Low',
    description: '480p • Fast export',
    icon: Icons.speed_rounded,
  );

  static const medium = QualityPreset(
    id: 'medium',
    name: 'Medium',
    description: '720p • Balanced',
    icon: Icons.equalizer_rounded,
  );

  static const high = QualityPreset(
    id: 'high',
    name: 'High',
    description: '1080p • Recommended',
    icon: Icons.high_quality_rounded,
  );

  static const ultra = QualityPreset(
    id: 'ultra',
    name: 'Ultra',
    description: '4K • Maximum quality',
    icon: Icons.hd_rounded,
  );

  static const List<QualityPreset> all = [low, medium, high, ultra];
}

/// Export screen
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, this.videoId, this.onClose});

  final String? videoId;
  final VoidCallback? onClose;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _selectedQuality = 'high';
  String _selectedFormat = 'mp4';
  String? _selectedPlatform;
  final Set<String> _batchPlatforms = {};
  bool _isExporting = false;
  double _exportProgress = 0;

  void _handlePlatformSelect(String platformId) {
    setState(() {
      _selectedPlatform = _selectedPlatform == platformId ? null : platformId;
    });
  }

  void _toggleBatchPlatform(String platformId) {
    setState(() {
      if (_batchPlatforms.contains(platformId)) {
        _batchPlatforms.remove(platformId);
      } else {
        _batchPlatforms.add(platformId);
      }
    });
  }

  Future<void> _startExport() async {
    if (widget.videoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No video to export')));
      return;
    }

    setState(() {
      _isExporting = true;
      _exportProgress = 0;
    });

    try {
      final api = ref.read(apiServiceProvider);

      if (_selectedPlatform != null) {
        await api.exportForPlatform(
          videoId: widget.videoId!,
          platform: _selectedPlatform!,
        );
      } else if (_batchPlatforms.isNotEmpty) {
        await api.batchExport(
          videoId: widget.videoId!,
          platforms: _batchPlatforms.toList(),
        );
      } else {
        await api.exportVideo(
          videoId: widget.videoId!,
          format: _selectedFormat,
          quality: _selectedQuality,
        );
      }

      // Simulate progress
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() => _exportProgress = i / 100);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export complete! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose ?? () => Navigator.pop(context),
        ),
        title: Text('Export', style: AppTextStyles.titleLarge),
        actions: [
          if (_isExporting)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: _exportProgress,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform presets section
            _buildSectionHeader('Quick Export', Icons.rocket_launch_rounded),
            const SizedBox(height: AppSizes.spacing12),
            _buildPlatformGrid(),
            const SizedBox(height: AppSizes.spacing32),

            // Custom export section
            _buildSectionHeader('Custom Export', Icons.tune_rounded),
            const SizedBox(height: AppSizes.spacing12),
            _buildQualitySelector(),
            const SizedBox(height: AppSizes.spacing16),
            _buildFormatSelector(),
            const SizedBox(height: AppSizes.spacing32),

            // Batch export section
            _buildSectionHeader('Batch Export', Icons.layers_rounded),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Export to multiple platforms at once',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            _buildBatchSelector(),
            const SizedBox(height: AppSizes.spacing32),

            // Export button
            _buildExportButton(),
            const SizedBox(height: AppSizes.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.spacing8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: Platforms.all.length,
      itemBuilder: (context, index) {
        final platform = Platforms.all[index];
        final isSelected = _selectedPlatform == platform.id;
        return _PlatformCard(
          platform: platform,
          isSelected: isSelected,
          onTap: () => _handlePlatformSelect(platform.id),
        );
      },
    );
  }

  Widget _buildQualitySelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Row(
            children: Qualities.all.map((quality) {
              final isSelected = _selectedQuality == quality.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedQuality = quality.id),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          quality.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quality.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    final formats = ['mp4', 'webm', 'mov', 'gif'];
    final formatLabels = {
      'mp4': 'MP4 (Universal)',
      'webm': 'WebM (Web)',
      'mov': 'MOV (Apple)',
      'gif': 'GIF (Animated)',
    };

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Format',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: formats.map((format) {
              final isSelected = _selectedFormat == format;
              return GestureDetector(
                onTap: () => setState(() => _selectedFormat = format),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    formatLabels[format]!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Platforms.all.map((platform) {
        final isSelected = _batchPlatforms.contains(platform.id);
        return GestureDetector(
          onTap: () => _toggleBatchPlatform(platform.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? platform.color.withOpacity(0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? platform.color : AppColors.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  platform.icon,
                  size: 16,
                  color: isSelected ? platform.color : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  platform.name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? platform.color
                        : AppColors.textSecondary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle, size: 14, color: platform.color),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExportButton() {
    final hasSelection =
        _selectedPlatform != null ||
        _batchPlatforms.isNotEmpty ||
        _selectedQuality.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasSelection && !_isExporting ? _startExport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          elevation: 0,
        ),
        child: _isExporting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Exporting... ${(_exportProgress * 100).toInt()}%',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_rounded),
                  const SizedBox(width: 8),
                  Text(
                    _batchPlatforms.isNotEmpty
                        ? 'Export to ${_batchPlatforms.length} Platforms'
                        : _selectedPlatform != null
                        ? 'Export for ${Platforms.all.firstWhere((p) => p.id == _selectedPlatform).name}'
                        : 'Export Video',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Platform card widget
class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  final PlatformPreset platform;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.spacing12),
        decoration: BoxDecoration(
          color: isSelected
              ? platform.color.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected ? platform.color : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: platform.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(platform.icon, color: platform.color, size: 24),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    platform.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? platform.color
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    platform.resolution,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    platform.description,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: platform.color, size: 20),
          ],
        ),
      ),
    );
  }
}
