/// Filters Panel for VibeEdit AI
/// Color presets and LUTs
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Filter preset model
class FilterPreset {
  const FilterPreset({
    required this.id,
    required this.name,
    required this.colors,
    this.intensity = 1.0,
  });

  final String id;
  final String name;
  final List<Color> colors;
  final double intensity;
}

/// Available filter presets
class Filters {
  static const none = FilterPreset(
    id: 'none',
    name: 'None',
    colors: [Colors.transparent, Colors.transparent],
  );
  static const vintage = FilterPreset(
    id: 'vintage',
    name: 'Vintage',
    colors: [Color(0x40D4A574), Color(0x30FFE4B5)],
  );
  static const cold = FilterPreset(
    id: 'cold',
    name: 'Cold',
    colors: [Color(0x3087CEEB), Color(0x20B0E0E6)],
  );
  static const warm = FilterPreset(
    id: 'warm',
    name: 'Warm',
    colors: [Color(0x40FFA500), Color(0x30FFD700)],
  );
  static const sepia = FilterPreset(
    id: 'sepia',
    name: 'Sepia',
    colors: [Color(0x50704214), Color(0x30C19A6B)],
  );
  static const noir = FilterPreset(
    id: 'noir',
    name: 'Noir',
    colors: [Color(0x60000000), Color(0x40333333)],
  );
  static const vivid = FilterPreset(
    id: 'vivid',
    name: 'Vivid',
    colors: [Color(0x20FF1493), Color(0x2000CED1)],
  );
  static const muted = FilterPreset(
    id: 'muted',
    name: 'Muted',
    colors: [Color(0x30808080), Color(0x20A9A9A9)],
  );
  static const sunset = FilterPreset(
    id: 'sunset',
    name: 'Sunset',
    colors: [Color(0x40FF6347), Color(0x30FF8C00)],
  );
  static const ocean = FilterPreset(
    id: 'ocean',
    name: 'Ocean',
    colors: [Color(0x3020B2AA), Color(0x20008B8B)],
  );
  static const forest = FilterPreset(
    id: 'forest',
    name: 'Forest',
    colors: [Color(0x30228B22), Color(0x2032CD32)],
  );
  static const neon = FilterPreset(
    id: 'neon',
    name: 'Neon',
    colors: [Color(0x30FF00FF), Color(0x2000FFFF)],
  );

  static const List<FilterPreset> all = [
    none,
    vintage,
    cold,
    warm,
    sepia,
    noir,
    vivid,
    muted,
    sunset,
    ocean,
    forest,
    neon,
  ];
}

/// Filters Panel
class FiltersPanel extends StatefulWidget {
  const FiltersPanel({super.key, this.onFilterSelected, this.onClose});

  final void Function(FilterPreset filter, double intensity)? onFilterSelected;
  final VoidCallback? onClose;

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  String _selectedId = 'none';
  double _intensity = 1.0;

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

          // Filters list
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing12,
              ),
              itemCount: Filters.all.length,
              itemBuilder: (context, index) {
                final filter = Filters.all[index];
                final isSelected = filter.id == _selectedId;
                return _FilterItem(
                  filter: filter,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedId = filter.id);
                    widget.onFilterSelected?.call(filter, _intensity);
                  },
                );
              },
            ),
          ),

          // Intensity slider
          _buildIntensitySlider(),
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
          Icon(Icons.filter_vintage_rounded, color: AppColors.accent),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Filters',
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

  Widget _buildIntensitySlider() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Text(
            'Intensity',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: _intensity,
                min: 0.0,
                max: 1.0,
                onChanged: (v) {
                  setState(() => _intensity = v);
                  final filter = Filters.all.firstWhere(
                    (f) => f.id == _selectedId,
                  );
                  widget.onFilterSelected?.call(filter, v);
                },
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              '${(_intensity * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  const _FilterItem({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  final FilterPreset filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: filter.colors.isEmpty
                      ? [AppColors.surfaceLight, AppColors.surfaceLight]
                      : filter.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.panelBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: filter.id == 'none'
                  ? Icon(Icons.not_interested, color: AppColors.textTertiary)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              filter.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
