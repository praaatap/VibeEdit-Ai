/// AI Enhance Panel for VibeEdit AI
/// Automatic quality improvements (UI stub)
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

class AIEnhancePanel extends StatefulWidget {
  const AIEnhancePanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<AIEnhancePanel> createState() => _AIEnhancePanelState();
}

class _AIEnhancePanelState extends State<AIEnhancePanel> {
  bool _denoise = true;
  bool _sharpen = true;
  bool _hdr = false;
  double _upscale = 1.0;
  bool _isProcessing = false;

  Future<void> _apply() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI enhancements applied (stub).')),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              children: [
                SwitchListTile(
                  value: _denoise,
                  onChanged: (v) => setState(() => _denoise = v),
                  title: const Text('Denoise'),
                  activeColor: AppColors.neonCyan,
                ),
                SwitchListTile(
                  value: _sharpen,
                  onChanged: (v) => setState(() => _sharpen = v),
                  title: const Text('Sharpen'),
                  activeColor: AppColors.neonCyan,
                ),
                SwitchListTile(
                  value: _hdr,
                  onChanged: (v) => setState(() => _hdr = v),
                  title: const Text('HDR Boost'),
                  activeColor: AppColors.neonCyan,
                ),
                const SizedBox(height: AppSizes.spacing16),
                Text('Upscale', style: AppTextStyles.titleSmall),
                Slider(
                  value: _upscale,
                  min: 1.0,
                  max: 2.0,
                  divisions: 4,
                  label: '${_upscale.toStringAsFixed(1)}x',
                  onChanged: (v) => setState(() => _upscale = v),
                ),
                const SizedBox(height: AppSizes.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _apply,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: Text(_isProcessing ? 'Applying...' : 'Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
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
          Icon(Icons.auto_fix_high_rounded, color: AppColors.neonCyan),
          const SizedBox(width: AppSizes.spacing8),
          Text('AI Enhance', style: AppTextStyles.titleMedium),
          const Spacer(),
          _aiBadge(AppColors.neonCyan),
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
