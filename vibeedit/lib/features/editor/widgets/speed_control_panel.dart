/// Speed Control Panel for VibeEdit AI
/// Speed adjustment: slow-mo, fast forward, reverse
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Speed preset
class SpeedPreset {
  const SpeedPreset({required this.label, required this.value});

  final String label;
  final double value;
}

/// Speed Control Panel
class SpeedControlPanel extends StatefulWidget {
  const SpeedControlPanel({
    super.key,
    this.onSpeedChanged,
    this.onReverseToggled,
    this.onClose,
  });

  final void Function(double speed)? onSpeedChanged;
  final void Function(bool reverse)? onReverseToggled;
  final VoidCallback? onClose;

  @override
  State<SpeedControlPanel> createState() => _SpeedControlPanelState();
}

class _SpeedControlPanelState extends State<SpeedControlPanel> {
  double _speed = 1.0;
  bool _reverse = false;
  bool _maintainPitch = true;

  static const List<SpeedPreset> _presets = [
    SpeedPreset(label: '0.25x', value: 0.25),
    SpeedPreset(label: '0.5x', value: 0.5),
    SpeedPreset(label: '0.75x', value: 0.75),
    SpeedPreset(label: '1x', value: 1.0),
    SpeedPreset(label: '1.5x', value: 1.5),
    SpeedPreset(label: '2x', value: 2.0),
    SpeedPreset(label: '3x', value: 3.0),
    SpeedPreset(label: '4x', value: 4.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Speed display
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              children: [
                // Speed value display
                Text(
                  '${_speed.toStringAsFixed(2)}x',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  _getSpeedLabel(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Preset buttons
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final isSelected = (_speed - preset.value).abs() < 0.01;
                return GestureDetector(
                  onTap: () {
                    setState(() => _speed = preset.value);
                    widget.onSpeedChanged?.call(_speed);
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
                      preset.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSizes.spacing16),

          // Speed slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: _speed,
                min: 0.25,
                max: 4.0,
                divisions: 15,
                onChanged: (v) {
                  setState(() => _speed = v);
                  widget.onSpeedChanged?.call(v);
                },
              ),
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Row(
              children: [
                // Reverse toggle
                Expanded(
                  child: _OptionButton(
                    icon: Icons.replay_rounded,
                    label: 'Reverse',
                    isActive: _reverse,
                    onTap: () {
                      setState(() => _reverse = !_reverse);
                      widget.onReverseToggled?.call(_reverse);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),
                // Maintain pitch toggle
                Expanded(
                  child: _OptionButton(
                    icon: Icons.music_note_rounded,
                    label: 'Keep Pitch',
                    isActive: _maintainPitch,
                    onTap: () =>
                        setState(() => _maintainPitch = !_maintainPitch),
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
          Icon(Icons.speed_rounded, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Speed',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _speed = 1.0;
                _reverse = false;
              });
              widget.onSpeedChanged?.call(1.0);
            },
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

  String _getSpeedLabel() {
    if (_speed < 0.5) return 'Super Slow Motion';
    if (_speed < 1.0) return 'Slow Motion';
    if (_speed == 1.0) return 'Normal Speed';
    if (_speed <= 2.0) return 'Fast';
    return 'Super Fast';
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.panelBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
