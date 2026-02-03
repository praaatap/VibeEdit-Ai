/// Dual preview widgets (Source & Program) similar to pro editors
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import 'video_preview.dart';

class DualPreview extends StatelessWidget {
  const DualPreview({
    super.key,
    required this.program,
    this.source,
  });

  final Widget program;
  final Widget? source;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _PreviewPanel(title: 'Source', child: source ?? _PlaceholderPreview())),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(child: _PreviewPanel(title: 'Program', child: program)),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.cardBorder),
              left: BorderSide(color: AppColors.cardBorder),
              right: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Text(title, style: AppTextStyles.labelSmall),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(color: AppColors.cardGlow, blurRadius: 20, spreadRadius: -5),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _PlaceholderPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSizes.videoPreviewAspectRatio,
      child: Container(
        color: AppColors.backgroundLight,
        alignment: Alignment.center,
        child: Text('No source loaded', style: AppTextStyles.bodySmall),
      ),
    );
  }
}
