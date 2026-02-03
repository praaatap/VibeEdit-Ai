/// Transitions Panel for VibeEdit AI
/// Apply transitions between clips
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Transition type model
class TransitionType {
  const TransitionType({
    required this.id,
    required this.name,
    required this.icon,
    this.duration = const Duration(milliseconds: 500),
  });

  final String id;
  final String name;
  final IconData icon;
  final Duration duration;
}

/// Available transitions
class Transitions {
  static const fade = TransitionType(
    id: 'fade',
    name: 'Fade',
    icon: Icons.gradient_rounded,
  );
  static const dissolve = TransitionType(
    id: 'dissolve',
    name: 'Dissolve',
    icon: Icons.blur_on_rounded,
  );
  static const slideLeft = TransitionType(
    id: 'slide_left',
    name: 'Slide Left',
    icon: Icons.arrow_back_rounded,
  );
  static const slideRight = TransitionType(
    id: 'slide_right',
    name: 'Slide Right',
    icon: Icons.arrow_forward_rounded,
  );
  static const slideUp = TransitionType(
    id: 'slide_up',
    name: 'Slide Up',
    icon: Icons.arrow_upward_rounded,
  );
  static const slideDown = TransitionType(
    id: 'slide_down',
    name: 'Slide Down',
    icon: Icons.arrow_downward_rounded,
  );
  static const zoom = TransitionType(
    id: 'zoom',
    name: 'Zoom',
    icon: Icons.zoom_in_rounded,
  );
  static const wipe = TransitionType(
    id: 'wipe',
    name: 'Wipe',
    icon: Icons.view_column_rounded,
  );
  static const flash = TransitionType(
    id: 'flash',
    name: 'Flash',
    icon: Icons.flash_on_rounded,
  );
  static const blur = TransitionType(
    id: 'blur',
    name: 'Blur',
    icon: Icons.blur_circular_rounded,
  );

  static const List<TransitionType> all = [
    fade,
    dissolve,
    slideLeft,
    slideRight,
    slideUp,
    slideDown,
    zoom,
    wipe,
    flash,
    blur,
  ];
}

/// Transitions Panel
class TransitionsPanel extends StatefulWidget {
  const TransitionsPanel({super.key, this.onTransitionSelected, this.onClose});

  final void Function(TransitionType transition)? onTransitionSelected;
  final VoidCallback? onClose;

  @override
  State<TransitionsPanel> createState() => _TransitionsPanelState();
}

class _TransitionsPanelState extends State<TransitionsPanel> {
  String? _selectedId;
  double _duration = 0.5;

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

          // Transitions grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: Transitions.all.length,
              itemBuilder: (context, index) {
                final transition = Transitions.all[index];
                final isSelected = transition.id == _selectedId;
                return _TransitionItem(
                  transition: transition,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedId = transition.id);
                    widget.onTransitionSelected?.call(transition);
                  },
                );
              },
            ),
          ),

          // Duration slider
          _buildDurationSlider(),
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
          Icon(Icons.swap_horiz_rounded, color: AppColors.accent),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Transitions',
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

  Widget _buildDurationSlider() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Text(
            'Duration',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.accent,
              ),
              child: Slider(
                value: _duration,
                min: 0.1,
                max: 2.0,
                onChanged: (v) => setState(() => _duration = v),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${_duration.toStringAsFixed(1)}s',
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

class _TransitionItem extends StatelessWidget {
  const _TransitionItem({
    required this.transition,
    required this.isSelected,
    required this.onTap,
  });

  final TransitionType transition;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.panelBorder,
              ),
            ),
            child: Icon(
              transition.icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transition.name,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.accent : AppColors.textTertiary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
