/// Crop & Rotate Panel for VibeEdit AI
/// Crop, rotate, and flip video
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Aspect ratio preset
class AspectRatioPreset {
  const AspectRatioPreset({
    required this.id,
    required this.name,
    required this.ratio,
  });

  final String id;
  final String name;
  final double? ratio; // null = free
}

/// Aspect ratio presets
class AspectRatios {
  static const free = AspectRatioPreset(id: 'free', name: 'Free', ratio: null);
  static const original = AspectRatioPreset(
    id: 'original',
    name: 'Original',
    ratio: null,
  );
  static const r16x9 = AspectRatioPreset(
    id: '16:9',
    name: '16:9',
    ratio: 16 / 9,
  );
  static const r9x16 = AspectRatioPreset(
    id: '9:16',
    name: '9:16',
    ratio: 9 / 16,
  );
  static const r4x3 = AspectRatioPreset(id: '4:3', name: '4:3', ratio: 4 / 3);
  static const r1x1 = AspectRatioPreset(id: '1:1', name: '1:1', ratio: 1);
  static const r4x5 = AspectRatioPreset(id: '4:5', name: '4:5', ratio: 4 / 5);
  static const r21x9 = AspectRatioPreset(
    id: '21:9',
    name: '21:9',
    ratio: 21 / 9,
  );

  static const List<AspectRatioPreset> all = [
    free,
    original,
    r16x9,
    r9x16,
    r4x3,
    r1x1,
    r4x5,
    r21x9,
  ];
}

/// Crop & Rotate Panel
class CropRotatePanel extends StatefulWidget {
  const CropRotatePanel({
    super.key,
    this.onRotationChanged,
    this.onFlipHorizontal,
    this.onFlipVertical,
    this.onAspectRatioChanged,
    this.onClose,
  });

  final void Function(double degrees)? onRotationChanged;
  final VoidCallback? onFlipHorizontal;
  final VoidCallback? onFlipVertical;
  final void Function(AspectRatioPreset ratio)? onAspectRatioChanged;
  final VoidCallback? onClose;

  @override
  State<CropRotatePanel> createState() => _CropRotatePanelState();
}

class _CropRotatePanelState extends State<CropRotatePanel> {
  double _rotation = 0.0;
  bool _flippedH = false;
  bool _flippedV = false;
  String _selectedRatioId = 'original';

  void _reset() {
    setState(() {
      _rotation = 0.0;
      _flippedH = false;
      _flippedV = false;
      _selectedRatioId = 'original';
    });
  }

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

          // Rotation controls
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rotation',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Row(
                  children: [
                    // Rotation slider
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.primary,
                        ),
                        child: Slider(
                          value: _rotation,
                          min: -180,
                          max: 180,
                          divisions: 72,
                          onChanged: (v) {
                            setState(() => _rotation = v);
                            widget.onRotationChanged?.call(v);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_rotation.toInt()}°',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick rotate & flip buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.rotate_left_rounded,
                  label: '-90°',
                  onTap: () {
                    setState(() => _rotation = (_rotation - 90) % 360);
                    widget.onRotationChanged?.call(_rotation);
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.rotate_right_rounded,
                  label: '+90°',
                  onTap: () {
                    setState(() => _rotation = (_rotation + 90) % 360);
                    widget.onRotationChanged?.call(_rotation);
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.flip_rounded,
                  label: 'Flip H',
                  isActive: _flippedH,
                  onTap: () {
                    setState(() => _flippedH = !_flippedH);
                    widget.onFlipHorizontal?.call();
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.flip_rounded,
                  label: 'Flip V',
                  isActive: _flippedV,
                  rotateIcon: true,
                  onTap: () {
                    setState(() => _flippedV = !_flippedV);
                    widget.onFlipVertical?.call();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spacing16),

          // Aspect ratio presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aspect Ratio',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AspectRatios.all.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final ratio = AspectRatios.all[index];
                      final isSelected = ratio.id == _selectedRatioId;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedRatioId = ratio.id);
                          widget.onAspectRatioChanged?.call(ratio);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.panelBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            ratio.name,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
          Icon(Icons.crop_rotate_rounded, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Crop & Rotate',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.textSecondary),
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.rotateIcon = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool rotateIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.panelBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: rotateIcon ? 1.5708 : 0, // 90 degrees
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
