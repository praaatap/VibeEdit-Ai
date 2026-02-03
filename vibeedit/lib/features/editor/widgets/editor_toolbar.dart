/// Editor toolbar widget for VibeEdit AI
/// Professional tool buttons for video editing (15 tools)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Tool data model
class EditorTool {
  const EditorTool({
    required this.id,
    required this.icon,
    required this.label,
    this.category = ToolCategory.edit,
  });

  final String id;
  final IconData icon;
  final String label;
  final ToolCategory category;
}

/// Tool categories
enum ToolCategory { edit, effects, audio, ai, export }

/// All 15 professional editor tools
class EditorTools {
  // Edit Tools
  static const cut = EditorTool(
    id: 'cut',
    icon: Icons.content_cut_rounded,
    label: 'Cut',
    category: ToolCategory.edit,
  );
  static const split = EditorTool(
    id: 'split',
    icon: Icons.call_split_rounded,
    label: 'Split',
    category: ToolCategory.edit,
  );
  static const speed = EditorTool(
    id: 'speed',
    icon: Icons.speed_rounded,
    label: 'Speed',
    category: ToolCategory.edit,
  );
  static const cropRotate = EditorTool(
    id: 'crop_rotate',
    icon: Icons.crop_rotate_rounded,
    label: 'Crop',
    category: ToolCategory.edit,
  );

  // Effects Tools
  static const filters = EditorTool(
    id: 'filters',
    icon: Icons.filter_vintage_rounded,
    label: 'Filters',
    category: ToolCategory.effects,
  );
  static const effects = EditorTool(
    id: 'effects',
    icon: Icons.auto_awesome_rounded,
    label: 'Effects',
    category: ToolCategory.effects,
  );
  static const colorGrading = EditorTool(
    id: 'color_grading',
    icon: Icons.palette_rounded,
    label: 'Color',
    category: ToolCategory.effects,
  );
  static const transitions = EditorTool(
    id: 'transitions',
    icon: Icons.swap_horiz_rounded,
    label: 'Transition',
    category: ToolCategory.effects,
  );
  static const chromaKey = EditorTool(
    id: 'chroma_key',
    icon: Icons.wallpaper_rounded,
    label: 'Chroma',
    category: ToolCategory.effects,
  );

  // Audio Tools
  static const volume = EditorTool(
    id: 'volume',
    icon: Icons.volume_up_rounded,
    label: 'Volume',
    category: ToolCategory.audio,
  );
  static const music = EditorTool(
    id: 'music',
    icon: Icons.music_note_rounded,
    label: 'Music',
    category: ToolCategory.audio,
  );

  // AI Tools
  static const text = EditorTool(
    id: 'text',
    icon: Icons.text_fields_rounded,
    label: 'Text',
    category: ToolCategory.ai,
  );
  static const captions = EditorTool(
    id: 'captions',
    icon: Icons.closed_caption_rounded,
    label: 'Captions',
    category: ToolCategory.ai,
  );
  static const stabilize = EditorTool(
    id: 'stabilize',
    icon: Icons.straighten_rounded,
    label: 'Stabilize',
    category: ToolCategory.ai,
  );

  // Gen AI Tools (new)
  static const aiGenerate = EditorTool(
    id: 'ai_generate',
    icon: Icons.bolt_rounded,
    label: 'Generate',
    category: ToolCategory.ai,
  );
  static const aiEnhance = EditorTool(
    id: 'ai_enhance',
    icon: Icons.auto_fix_high_rounded,
    label: 'Enhance',
    category: ToolCategory.ai,
  );
  static const aiRemix = EditorTool(
    id: 'ai_remix',
    icon: Icons.shuffle_rounded,
    label: 'Remix',
    category: ToolCategory.ai,
  );
  static const styleTransfer = EditorTool(
    id: 'style_transfer',
    icon: Icons.brush_rounded,
    label: 'Style',
    category: ToolCategory.ai,
  );
  static const aiSuggestions = EditorTool(
    id: 'ai_suggestions',
    icon: Icons.lightbulb_rounded,
    label: 'Suggest',
    category: ToolCategory.ai,
  );

  // Export
  static const exportTool = EditorTool(
    id: 'export',
    icon: Icons.file_upload_rounded,
    label: 'Export',
    category: ToolCategory.export,
  );

  static const List<EditorTool> all = [
    cut,
    split,
    speed,
    cropRotate,
    filters,
    effects,
    colorGrading,
    transitions,
    chromaKey,
    volume,
    music,
    text,
    captions,
    stabilize,
    aiGenerate,
    aiEnhance,
    aiRemix,
    styleTransfer,
    aiSuggestions,
    exportTool,
  ];
}

/// Editor toolbar with horizontal scroll
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key, this.selectedToolId, this.onToolTap});

  final String? selectedToolId;
  final void Function(EditorTool tool)? onToolTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border(top: BorderSide(color: AppColors.panelBorder, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing8),
        child: Row(
          children: EditorTools.all.map((tool) {
            final isSelected = tool.id == selectedToolId;
            return _ToolButton(
              tool: tool,
              isSelected: isSelected,
              onTap: () => onToolTap?.call(tool),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  final EditorTool tool;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _categoryColor {
    switch (tool.category) {
      case ToolCategory.edit:
        return AppColors.primary;
      case ToolCategory.effects:
        return AppColors.accent;
      case ToolCategory.audio:
        return AppColors.audioTrack;
      case ToolCategory.ai:
        return AppColors.neonPink;
      case ToolCategory.export:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing12),
              decoration: BoxDecoration(
                color: isSelected ? _categoryColor : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? _categoryColor.withValues(alpha: 0.7)
                      : AppColors.panelBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                tool.icon,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSizes.spacing4),
            Text(
              tool.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? _categoryColor : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
