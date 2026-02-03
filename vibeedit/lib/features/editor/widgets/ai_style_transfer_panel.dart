/// AI Style Transfer Panel for VibeEdit AI
/// Apply artistic styles to video (UI stub)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

class AIStyleTransferPanel extends StatefulWidget {
  const AIStyleTransferPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<AIStyleTransferPanel> createState() => _AIStyleTransferPanelState();
}

class _AIStyleTransferPanelState extends State<AIStyleTransferPanel> {
  final List<String> _styles = [
    'Cinematic',
    'Anime',
    'Neon Noir',
    'Cyberpunk',
    'Vintage Film',
    'VHS',
  ];
  String _selected = 'Cinematic';
  bool _isApplying = false;

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() => _isApplying = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Style "$_selected" applied (stub).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _styles.map((s) {
                    final selected = s == _selected;
                    return ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _selected = s),
                      selectedColor: AppColors.neonPink,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                      backgroundColor: AppColors.surfaceLight,
                      side: BorderSide(color: AppColors.panelBorder),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isApplying ? null : _apply,
                    icon: const Icon(Icons.brush_rounded),
                    label: Text(_isApplying ? 'Applying...' : 'Apply Style'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPink,
                      foregroundColor: Colors.white,
                    ),
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
          Icon(Icons.brush_rounded, color: AppColors.neonPink),
          const SizedBox(width: AppSizes.spacing8),
          Text('Style Transfer', style: AppTextStyles.titleMedium),
          const Spacer(),
          _aiBadge(AppColors.neonPink),
          const SizedBox(width: AppSizes.spacing8),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _aiBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: color),
          const SizedBox(width: 4),
          Text('AI', style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
