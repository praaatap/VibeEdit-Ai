/// Color Grading Panel for VibeEdit AI
/// Brightness, contrast, saturation, temperature controls
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Color grading values
class ColorGradingValues {
  ColorGradingValues({
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
    this.exposure = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
  });

  double brightness;
  double contrast;
  double saturation;
  double temperature;
  double tint;
  double exposure;
  double highlights;
  double shadows;

  ColorGradingValues copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? tint,
    double? exposure,
    double? highlights,
    double? shadows,
  }) {
    return ColorGradingValues(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      exposure: exposure ?? this.exposure,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
    );
  }

  void reset() {
    brightness = 0.0;
    contrast = 0.0;
    saturation = 0.0;
    temperature = 0.0;
    tint = 0.0;
    exposure = 0.0;
    highlights = 0.0;
    shadows = 0.0;
  }
}

/// Color Grading Panel
class ColorGradingPanel extends StatefulWidget {
  const ColorGradingPanel({super.key, this.onValuesChanged, this.onClose});

  final void Function(ColorGradingValues values)? onValuesChanged;
  final VoidCallback? onClose;

  @override
  State<ColorGradingPanel> createState() => _ColorGradingPanelState();
}

class _ColorGradingPanelState extends State<ColorGradingPanel> {
  final ColorGradingValues _values = ColorGradingValues();

  void _onValueChanged() {
    widget.onValuesChanged?.call(_values);
  }

  void _reset() {
    setState(() => _values.reset());
    _onValueChanged();
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

          // Sliders
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Column(
                children: [
                  _ColorSlider(
                    label: 'Brightness',
                    icon: Icons.brightness_6_rounded,
                    value: _values.brightness,
                    color: Colors.amber,
                    onChanged: (v) {
                      setState(() => _values.brightness = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Contrast',
                    icon: Icons.contrast_rounded,
                    value: _values.contrast,
                    color: AppColors.textPrimary,
                    onChanged: (v) {
                      setState(() => _values.contrast = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Saturation',
                    icon: Icons.water_drop_rounded,
                    value: _values.saturation,
                    color: Colors.pinkAccent,
                    onChanged: (v) {
                      setState(() => _values.saturation = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Temperature',
                    icon: Icons.thermostat_rounded,
                    value: _values.temperature,
                    color: Colors.orange,
                    onChanged: (v) {
                      setState(() => _values.temperature = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Exposure',
                    icon: Icons.exposure_rounded,
                    value: _values.exposure,
                    color: Colors.white70,
                    onChanged: (v) {
                      setState(() => _values.exposure = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Highlights',
                    icon: Icons.wb_sunny_rounded,
                    value: _values.highlights,
                    color: Colors.yellowAccent,
                    onChanged: (v) {
                      setState(() => _values.highlights = v);
                      _onValueChanged();
                    },
                  ),
                  _ColorSlider(
                    label: 'Shadows',
                    icon: Icons.nights_stay_rounded,
                    value: _values.shadows,
                    color: Colors.deepPurple,
                    onChanged: (v) {
                      setState(() => _values.shadows = v);
                      _onValueChanged();
                    },
                  ),
                ],
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
          Icon(Icons.palette_rounded, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Color Grading',
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

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSizes.spacing12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: color,
                trackHeight: 3,
              ),
              child: Slider(
                value: value,
                min: -1.0,
                max: 1.0,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).toInt()}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
