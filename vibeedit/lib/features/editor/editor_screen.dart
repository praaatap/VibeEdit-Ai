/// Editor screen for VibeEdit AI
/// Main video editing interface
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../ai_copilot/ai_copilot_screen.dart';
import 'widgets/widgets.dart';

/// Video editor screen
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.project, required this.onBack});

  final Project project;
  final VoidCallback onBack;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String? _selectedToolId;

  @override
  void initState() {
    super.initState();
    // Load project into editor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editorProvider.notifier).loadProject(widget.project);
    });
  }

  void _handleToolTap(EditorTool tool) {
    setState(() {
      _selectedToolId = _selectedToolId == tool.id ? null : tool.id;
    });

    // Handle specific tools
    if (tool.id == 'split') {
      ref.read(editorProvider.notifier).splitAtPlayhead();
      return;
    }

    // Open panels for AI tools and captions
    switch (tool.id) {
      case 'captions':
        _openBottomPanel(
          AutoCaptionsPanel(onClose: () => Navigator.of(context).pop()),
        );
        break;
      case 'ai_generate':
        _openBottomPanel(
          AIGenerationPanel(onClose: () => Navigator.of(context).pop()),
        );
        break;
      case 'ai_enhance':
        _openBottomPanel(
          AIEnhancePanel(onClose: () => Navigator.of(context).pop()),
        );
        break;
      case 'style_transfer':
        _openBottomPanel(
          AIStyleTransferPanel(onClose: () => Navigator.of(context).pop()),
        );
        break;
      case 'ai_suggestions':
        _openBottomPanel(
          AISuggestionsPanel(onClose: () => Navigator.of(context).pop()),
        );
        break;
      default:
        break;
    }
  }

  void _openBottomPanel(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }

  void _openAICopilot() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AICopilotScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final project = editorState.project ?? widget.project;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(editorState),
      body: SafeArea(
        child: Column(
          children: [
            // Dual previews (Source & Program)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing8,
              ),
              child: DualPreview(
                source: null, // Hook up to selected clip preview later
                program: VideoPreview(
                  currentTime: editorState.formattedCurrentTime,
                  isPlaying: editorState.isPlaying,
                  onPlayPause: () {
                    ref.read(editorProvider.notifier).togglePlayback();
                  },
                ),
              ),
            ),

            // Playback controls
            PlaybackControls(
              currentTime: editorState.formattedCurrentTime,
              totalTime: editorState.formattedTotalTime,
              isPlaying: editorState.isPlaying,
              onPlayPause: () {
                ref.read(editorProvider.notifier).togglePlayback();
              },
              onSkipBack: () {
                ref.read(editorProvider.notifier).skipToStart();
              },
              onSkipForward: () {
                ref.read(editorProvider.notifier).skipToEnd();
              },
            ),

            // Timeline with track headers
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.timelineGradient,
                  border: Border(
                    top: BorderSide(color: AppColors.cardBorder, width: 1),
                  ),
                ),
                child: TimelineWidget(
                  tracks: project.tracks,
                  currentTime: editorState.currentTime,
                  totalDuration: project.duration,
                  zoom: editorState.zoom,
                  selectedClipId: editorState.selectedClipId,
                  onClipTap: (clipId, trackId) {
                    ref
                        .read(editorProvider.notifier)
                        .selectClip(clipId, trackId: trackId);
                  },
                ),
              ),
            ),

            // Project bin panel
            ProjectBinPanel(
              project: project,
              onTapClip: (clipId) {
                // TODO: preview the clip in Source monitor
              },
            ),

            // AI Copilot FAB row
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing12,
              ),
              decoration: BoxDecoration(
                color: AppColors.panelBackground,
                border: Border(
                  top: BorderSide(color: AppColors.panelBorder, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AICopilotFab(onTap: _openAICopilot),
                  const SizedBox(width: AppSizes.spacing12),
                  VoiceMicButton(onTap: _openAICopilot),
                ],
              ),
            ),

            // Toolbar with gradient background
            EditorToolbar(
              selectedToolId: _selectedToolId,
              onToolTap: _handleToolTap,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(EditorState editorState) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBack,
      ),
      title: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.undo,
              color: editorState.canUndo
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
            onPressed: editorState.canUndo
                ? () => ref.read(editorProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: Icon(
              Icons.redo,
              color: editorState.canRedo
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
            onPressed: editorState.canRedo
                ? () => ref.read(editorProvider.notifier).redo()
                : null,
          ),
        ],
      ),
      actions: [
        // Resolution selector
        Container(
          margin: const EdgeInsets.only(right: AppSizes.spacing8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            children: [
              Text('1080P', style: AppTextStyles.labelMedium),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        ),

        // Export button
        Container(
          margin: const EdgeInsets.only(right: AppSizes.spacing16),
          child: ElevatedButton(
            onPressed: () {
              ref.read(editorProvider.notifier).startExport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(AppStrings.export, style: AppTextStyles.labelMedium),
          ),
        ),
      ],
    );
  }
}
