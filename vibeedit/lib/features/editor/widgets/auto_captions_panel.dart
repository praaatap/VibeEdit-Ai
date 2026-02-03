/// Auto Captions Panel for VibeEdit AI
/// Uses OpenAI Whisper for speech-to-text
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/whisper_service.dart';

/// Provider for Whisper service
final whisperServiceProvider = Provider((ref) => WhisperService());

/// Auto Captions Panel
class AutoCaptionsPanel extends ConsumerStatefulWidget {
  const AutoCaptionsPanel({
    super.key,
    this.videoPath,
    this.onCaptionsGenerated,
    this.onClose,
  });

  final String? videoPath;
  final void Function(TranscriptionResult result)? onCaptionsGenerated;
  final VoidCallback? onClose;

  @override
  ConsumerState<AutoCaptionsPanel> createState() => _AutoCaptionsPanelState();
}

class _AutoCaptionsPanelState extends ConsumerState<AutoCaptionsPanel> {
  TranscriptionResult? _result;
  bool _isGenerating = false;
  String _selectedStyle = 'Default';

  final List<String> _captionStyles = [
    'Default',
    'Bold',
    'Minimal',
    'Outline',
    'Glow',
  ];

  Future<void> _generateCaptions() async {
    if (widget.videoPath == null) return;

    setState(() => _isGenerating = true);

    final whisper = ref.read(whisperServiceProvider);
    final result = await whisper.generateCaptions(widget.videoPath!);

    setState(() {
      _isGenerating = false;
      _result = result;
    });

    if (result != null) {
      widget.onCaptionsGenerated?.call(result);
    }
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

          // Content
          Expanded(
            child: _isGenerating
                ? _buildGeneratingState()
                : _result != null
                ? _buildCaptionsList()
                : _buildInitialState(),
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
          Icon(Icons.closed_caption_rounded, color: AppColors.neonPink),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Auto Captions',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing8,
              vertical: AppSizes.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.neonPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: AppColors.neonPink),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neonPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacing8),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Generate Captions',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'AI will transcribe your video audio\ninto captions automatically',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Style selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _captionStyles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final style = _captionStyles[index];
                final isSelected = style == _selectedStyle;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = style),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.neonPink
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.neonPink
                            : AppColors.panelBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      style,
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

          const SizedBox(height: AppSizes.spacing24),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateCaptions,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Captions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.neonPink,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Generating captions...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Powered by OpenAI Whisper',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _result!.segments.length,
      itemBuilder: (context, index) {
        final segment = _result!.segments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
          padding: const EdgeInsets.all(AppSizes.spacing12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatTime(segment.startTime),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neonPink,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Text(
                  segment.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit, size: 18, color: AppColors.textTertiary),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
