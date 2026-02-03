/// Text/Titles Panel for VibeEdit AI
/// Add text overlays with styling options
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Text style preset
class TextStylePreset {
  const TextStylePreset({
    required this.id,
    required this.name,
    required this.color,
    required this.backgroundColor,
    this.fontWeight = FontWeight.normal,
    this.hasOutline = false,
    this.hasShadow = false,
  });

  final String id;
  final String name;
  final Color color;
  final Color? backgroundColor;
  final FontWeight fontWeight;
  final bool hasOutline;
  final bool hasShadow;
}

/// Text style presets
class TextPresets {
  static const basic = TextStylePreset(
    id: 'basic',
    name: 'Basic',
    color: Colors.white,
    backgroundColor: null,
  );
  static const caption = TextStylePreset(
    id: 'caption',
    name: 'Caption',
    color: Colors.white,
    backgroundColor: Colors.black54,
  );
  static const bold = TextStylePreset(
    id: 'bold',
    name: 'Bold',
    color: Colors.white,
    backgroundColor: null,
    fontWeight: FontWeight.bold,
  );
  static const neon = TextStylePreset(
    id: 'neon',
    name: 'Neon',
    color: Color(0xFFFF00FF),
    backgroundColor: null,
    hasShadow: true,
  );
  static const outline = TextStylePreset(
    id: 'outline',
    name: 'Outline',
    color: Colors.white,
    backgroundColor: null,
    hasOutline: true,
  );
  static const retro = TextStylePreset(
    id: 'retro',
    name: 'Retro',
    color: Color(0xFFFFD700),
    backgroundColor: Color(0x80FF4500),
    fontWeight: FontWeight.bold,
  );

  static const List<TextStylePreset> all = [
    basic,
    caption,
    bold,
    neon,
    outline,
    retro,
  ];
}

/// Text/Titles Panel
class TextTitlesPanel extends StatefulWidget {
  const TextTitlesPanel({super.key, this.onTextAdded, this.onClose});

  final void Function(String text, TextStylePreset style)? onTextAdded;
  final VoidCallback? onClose;

  @override
  State<TextTitlesPanel> createState() => _TextTitlesPanelState();
}

class _TextTitlesPanelState extends State<TextTitlesPanel> {
  final TextEditingController _textController = TextEditingController();
  String _selectedPresetId = 'caption';
  double _fontSize = 24.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Text input
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: TextField(
              controller: _textController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter your text...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.panelBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.panelBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.textTrack),
                ),
              ),
            ),
          ),

          // Style presets
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              itemCount: TextPresets.all.length,
              itemBuilder: (context, index) {
                final preset = TextPresets.all[index];
                final isSelected = preset.id == _selectedPresetId;
                return _TextPresetItem(
                  preset: preset,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedPresetId = preset.id),
                );
              },
            ),
          ),

          // Font size slider
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.spacing12),
                Text(
                  'Size',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.textTrack,
                      inactiveTrackColor: AppColors.surfaceLight,
                      thumbColor: AppColors.textTrack,
                    ),
                    child: Slider(
                      value: _fontSize,
                      min: 12,
                      max: 72,
                      onChanged: (v) => setState(() => _fontSize = v),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${_fontSize.toInt()}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Add button
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    final preset = TextPresets.all.firstWhere(
                      (p) => p.id == _selectedPresetId,
                    );
                    widget.onTextAdded?.call(_textController.text, preset);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textTrack,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
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
          Icon(Icons.text_fields_rounded, color: AppColors.textTrack),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Text & Titles',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TextPresetItem extends StatelessWidget {
  const _TextPresetItem({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final TextStylePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: preset.backgroundColor ?? AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? AppColors.textTrack
                      : AppColors.panelBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Aa',
                style: TextStyle(
                  color: preset.color,
                  fontWeight: preset.fontWeight,
                  fontSize: 18,
                  shadows: preset.hasShadow
                      ? [Shadow(color: preset.color, blurRadius: 8)]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              preset.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.textTrack
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
