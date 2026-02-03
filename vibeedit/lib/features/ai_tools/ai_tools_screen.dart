/// AI Tools screen for VibeEdit AI
/// Browse and access all AI-powered editing features
library;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// AI category model
class AICategory {
  const AICategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.tools,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<AIToolItem> tools;
}

/// AI tool item
class AIToolItem {
  const AIToolItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isPro = false,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isPro;
}

/// AI categories with tools
final _categories = [
  AICategory(
    id: 'editing',
    name: 'Smart Editing',
    icon: Icons.movie_edit,
    color: AppColors.primary,
    tools: [
      AIToolItem(
        id: 'auto_cut',
        name: 'Auto Cut',
        description: 'AI finds the best moments',
        icon: Icons.content_cut_rounded,
      ),
      AIToolItem(
        id: 'smart_trim',
        name: 'Smart Trim',
        description: 'Remove silences & dead air',
        icon: Icons.cut_rounded,
      ),
      AIToolItem(
        id: 'scene_detect',
        name: 'Scene Detection',
        description: 'Auto-split by scenes',
        icon: Icons.auto_awesome_motion_rounded,
      ),
      AIToolItem(
        id: 'beat_sync',
        name: 'Beat Sync',
        description: 'Sync cuts to music beats',
        icon: Icons.graphic_eq_rounded,
        isPro: true,
      ),
    ],
  ),
  AICategory(
    id: 'enhancement',
    name: 'Enhancement',
    icon: Icons.auto_fix_high_rounded,
    color: AppColors.accent,
    tools: [
      AIToolItem(
        id: 'ai_enhance',
        name: 'AI Enhance',
        description: 'Improve quality automatically',
        icon: Icons.hd_rounded,
      ),
      AIToolItem(
        id: 'stabilize',
        name: 'Stabilize',
        description: 'Fix shaky footage',
        icon: Icons.vibration_rounded,
      ),
      AIToolItem(
        id: 'denoise',
        name: 'Noise Reduction',
        description: 'Clean up audio & video',
        icon: Icons.speaker_notes_off_rounded,
      ),
      AIToolItem(
        id: 'upscale',
        name: 'AI Upscale',
        description: 'Enhance to 4K',
        icon: Icons.aspect_ratio_rounded,
        isPro: true,
      ),
    ],
  ),
  AICategory(
    id: 'captions',
    name: 'Captions & Text',
    icon: Icons.closed_caption_rounded,
    color: Color(0xFF22C55E),
    tools: [
      AIToolItem(
        id: 'auto_captions',
        name: 'Auto Captions',
        description: 'Generate from speech',
        icon: Icons.subtitles_rounded,
      ),
      AIToolItem(
        id: 'translate',
        name: 'Translate',
        description: 'Multi-language subtitles',
        icon: Icons.translate_rounded,
      ),
      AIToolItem(
        id: 'animated_text',
        name: 'Animated Text',
        description: 'Kinetic typography',
        icon: Icons.text_fields_rounded,
      ),
      AIToolItem(
        id: 'ai_titles',
        name: 'AI Titles',
        description: 'Generate catchy titles',
        icon: Icons.title_rounded,
        isPro: true,
      ),
    ],
  ),
  AICategory(
    id: 'audio',
    name: 'Audio & Music',
    icon: Icons.music_note_rounded,
    color: Color(0xFFEC4899),
    tools: [
      AIToolItem(
        id: 'music_suggest',
        name: 'Music Suggestions',
        description: 'AI picks trending tracks',
        icon: Icons.library_music_rounded,
      ),
      AIToolItem(
        id: 'voice_enhance',
        name: 'Voice Enhance',
        description: 'Improve speech clarity',
        icon: Icons.record_voice_over_rounded,
      ),
      AIToolItem(
        id: 'sound_effects',
        name: 'Smart SFX',
        description: 'Add contextual sounds',
        icon: Icons.spatial_audio_rounded,
      ),
      AIToolItem(
        id: 'voice_clone',
        name: 'Voice Clone',
        description: 'AI voiceover',
        icon: Icons.mic_rounded,
        isPro: true,
      ),
    ],
  ),
  AICategory(
    id: 'creative',
    name: 'Creative Effects',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFF59E0B),
    tools: [
      AIToolItem(
        id: 'style_transfer',
        name: 'Style Transfer',
        description: 'Artistic video styles',
        icon: Icons.palette_rounded,
      ),
      AIToolItem(
        id: 'background_remove',
        name: 'Background Remove',
        description: 'AI green screen',
        icon: Icons.layers_clear_rounded,
      ),
      AIToolItem(
        id: 'object_remove',
        name: 'Object Remove',
        description: 'Erase unwanted items',
        icon: Icons.delete_sweep_rounded,
        isPro: true,
      ),
      AIToolItem(
        id: 'face_effects',
        name: 'Face Effects',
        description: 'Beauty & filters',
        icon: Icons.face_retouching_natural_rounded,
        isPro: true,
      ),
    ],
  ),
];

/// AI Tools screen
class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('AI Tools', style: AppTextStyles.titleLarge),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.workspace_premium,
              color: AppColors.warning,
              size: 18,
            ),
            label: Text('Pro', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacing24),
        itemBuilder: (context, index) {
          return _CategorySection(category: _categories[index]);
        },
      ),
    );
  }
}

/// Category section widget
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});

  final AICategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(category.name, style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),

        // Tools grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
          ),
          itemCount: category.tools.length,
          itemBuilder: (context, index) {
            return _ToolCard(
              tool: category.tools[index],
              color: category.color,
            );
          },
        ),
      ],
    );
  }
}

/// Tool card widget
class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.color});

  final AIToolItem tool;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${tool.name}...'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(tool.icon, color: color, size: 18),
                ),
                const Spacer(),
                if (tool.isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PRO',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tool.name,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tool.description,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
