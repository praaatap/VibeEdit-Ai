/// AI Generation Panel for VibeEdit AI
/// Prompt-based scene generation (UI stub)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

class AIGenerationPanel extends StatefulWidget {
  const AIGenerationPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<AIGenerationPanel> createState() => _AIGenerationPanelState();
}

class _AIGenerationPanelState extends State<AIGenerationPanel> {
  final TextEditingController _promptCtrl = TextEditingController();
  bool _isGenerating = false;

  Future<void> _generate() async {
    if (_promptCtrl.text.trim().isEmpty) return;
    setState(() => _isGenerating = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() => _isGenerating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI generation queued (stub).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
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
              children: [
                TextField(
                  controller: _promptCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the scene you want to generate... ',
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generate,
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPurple,
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
          Icon(Icons.bolt_rounded, color: AppColors.neonPurple),
          const SizedBox(width: AppSizes.spacing8),
          Text('AI Generate', style: AppTextStyles.titleMedium),
          const Spacer(),
          _aiBadge(AppColors.neonPurple),
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
