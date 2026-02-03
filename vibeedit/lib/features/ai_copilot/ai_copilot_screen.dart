/// AI Copilot screen for VibeEdit AI
/// Full-screen chat interface for AI editing commands
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/widgets.dart';

/// AI Copilot chat screen
class AICopilotScreen extends ConsumerStatefulWidget {
  const AICopilotScreen({super.key});

  @override
  ConsumerState<AICopilotScreen> createState() => _AICopilotScreenState();
}

class _AICopilotScreenState extends ConsumerState<AICopilotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  static const List<QuickAction> quickActions = [
    QuickAction(
      key: 'cut_silence',
      icon: Icons.content_cut,
      label: AppStrings.cutSilence,
    ),
    QuickAction(
      key: 'color_grade',
      icon: Icons.palette,
      label: AppStrings.colorGrade,
    ),
    QuickAction(key: 'speed', icon: Icons.speed, label: AppStrings.speed),
  ];

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(aiCopilotProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _onQuickAction(String actionKey) {
    ref.read(aiCopilotProvider.notifier).sendQuickAction(actionKey);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copilotState = ref.watch(aiCopilotProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(copilotState.isOnline),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing8,
              ),
              itemCount:
                  copilotState.messages.length +
                  (copilotState.processingMessage != null ? 1 : 0),
              itemBuilder: (context, index) {
                // Show processing message at the end
                if (index == copilotState.messages.length &&
                    copilotState.processingMessage != null) {
                  return ProcessingMessageBubble(
                    message: copilotState.processingMessage!,
                  );
                }

                final message = copilotState.messages[index];
                if (message.isUser) {
                  return UserMessageBubble(message: message);
                } else {
                  return AIMessageBubble(message: message);
                }
              },
            ),
          ),

          // Quick actions
          QuickActionChips(actions: quickActions, onActionTap: _onQuickAction),
          const SizedBox(height: AppSizes.spacing12),

          // Chat input
          ChatInput(
            controller: _textController,
            onSend: _sendMessage,
            isProcessing: copilotState.isProcessing,
          ),
          const SizedBox(height: AppSizes.spacing16),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isOnline) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.expand_more),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Text(AppStrings.aiCopilot, style: AppTextStyles.titleLarge),
          const SizedBox(width: AppSizes.spacing8),
          // Online badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing8,
              vertical: AppSizes.spacing4,
            ),
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.accent : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing4),
                Text(
                  AppStrings.online,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isOnline ? AppColors.accent : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
