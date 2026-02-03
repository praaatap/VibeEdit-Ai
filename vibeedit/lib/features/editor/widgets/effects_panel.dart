/// Effects Panel for VibeEdit AI
/// Visual effects: blur, glow, vignette, noise
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Effect type model
class VideoEffect {
  const VideoEffect({
    required this.id,
    required this.name,
    required this.icon,
    this.intensity = 0.5,
  });

  final String id;
  final String name;
  final IconData icon;
  final double intensity;
}

/// Available effects
class Effects {
  static const blur = VideoEffect(
    id: 'blur',
    name: 'Blur',
    icon: Icons.blur_on_rounded,
  );
  static const glow = VideoEffect(
    id: 'glow',
    name: 'Glow',
    icon: Icons.flare_rounded,
  );
  static const vignette = VideoEffect(
    id: 'vignette',
    name: 'Vignette',
    icon: Icons.vignette_rounded,
  );
  static const grain = VideoEffect(
    id: 'grain',
    name: 'Grain',
    icon: Icons.grain_rounded,
  );
  static const sharpen = VideoEffect(
    id: 'sharpen',
    name: 'Sharpen',
    icon: Icons.auto_fix_high_rounded,
  );
  static const pixelate = VideoEffect(
    id: 'pixelate',
    name: 'Pixelate',
    icon: Icons.grid_view_rounded,
  );
  static const glitch = VideoEffect(
    id: 'glitch',
    name: 'Glitch',
    icon: Icons.broken_image_rounded,
  );
  static const mirror = VideoEffect(
    id: 'mirror',
    name: 'Mirror',
    icon: Icons.flip_rounded,
  );
  static const zoom = VideoEffect(
    id: 'zoom',
    name: 'Zoom',
    icon: Icons.zoom_in_rounded,
  );
  static const shake = VideoEffect(
    id: 'shake',
    name: 'Shake',
    icon: Icons.vibration_rounded,
  );

  static const List<VideoEffect> all = [
    blur,
    glow,
    vignette,
    grain,
    sharpen,
    pixelate,
    glitch,
    mirror,
    zoom,
    shake,
  ];
}

/// Effects Panel
class EffectsPanel extends StatefulWidget {
  const EffectsPanel({super.key, this.onEffectApplied, this.onClose});

  final void Function(VideoEffect effect, double intensity)? onEffectApplied;
  final VoidCallback? onClose;

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel> {
  final Map<String, double> _appliedEffects = {};
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Effects grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: Effects.all.length,
              itemBuilder: (context, index) {
                final effect = Effects.all[index];
                final isSelected = effect.id == _selectedId;
                final isApplied = _appliedEffects.containsKey(effect.id);
                return _EffectItem(
                  effect: effect,
                  isSelected: isSelected,
                  isApplied: isApplied,
                  onTap: () => setState(() => _selectedId = effect.id),
                );
              },
            ),
          ),

          // Intensity slider
          if (_selectedId != null) _buildIntensitySlider(),
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
          Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Effects',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (_appliedEffects.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _appliedEffects.clear()),
              child: Text(
                'Clear All',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider() {
    final effect = Effects.all.firstWhere((e) => e.id == _selectedId);
    final intensity = _appliedEffects[_selectedId] ?? 0.5;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              effect.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.accent,
              ),
              child: Slider(
                value: intensity,
                min: 0.0,
                max: 1.0,
                onChanged: (v) {
                  setState(() => _appliedEffects[_selectedId!] = v);
                  widget.onEffectApplied?.call(effect, v);
                },
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              '${(intensity * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _appliedEffects[_selectedId!] = 0.5);
              widget.onEffectApplied?.call(effect, 0.5);
            },
            icon: Icon(Icons.add_circle, color: AppColors.success, size: 28),
          ),
        ],
      ),
    );
  }
}

class _EffectItem extends StatelessWidget {
  const _EffectItem({
    required this.effect,
    required this.isSelected,
    required this.isApplied,
    required this.onTap,
  });

  final VideoEffect effect;
  final bool isSelected;
  final bool isApplied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.panelBorder,
                  ),
                ),
                child: Icon(
                  effect.icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              if (isApplied)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            effect.name,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.accent : AppColors.textTertiary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
