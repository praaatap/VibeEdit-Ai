/// AI Copilot provider for VibeEdit AI
/// State management for AI chat interface using Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';

/// State class for AI Copilot
class AICopilotState {
  const AICopilotState({
    this.messages = const [],
    this.isOnline = true,
    this.isProcessing = false,
    this.processingMessage,
    this.error,
  });

  final List<AIMessage> messages;
  final bool isOnline;
  final bool isProcessing;
  final AIMessage? processingMessage;
  final String? error;

  AICopilotState copyWith({
    List<AIMessage>? messages,
    bool? isOnline,
    bool? isProcessing,
    AIMessage? processingMessage,
    String? error,
  }) {
    return AICopilotState(
      messages: messages ?? this.messages,
      isOnline: isOnline ?? this.isOnline,
      isProcessing: isProcessing ?? this.isProcessing,
      processingMessage: processingMessage,
      error: error,
    );
  }
}

/// AI Copilot state notifier
class AICopilotNotifier extends StateNotifier<AICopilotState> {
  AICopilotNotifier() : super(const AICopilotState());

  /// Quick action commands
  static const Map<String, String> quickActions = {
    'cut_silence': 'Cut all silent parts from the video',
    'color_grade': 'Apply cinematic color grading',
    'speed': 'Adjust the video speed',
    'add_captions': 'Generate and add captions',
    'remove_background': 'Remove the background from this clip',
    'stabilize': 'Stabilize shaky footage',
  };

  /// Send a message to AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AIMessage.user(content);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isProcessing: true,
    );

    // Simulate AI processing
    await _simulateAIResponse(content);
  }

  /// Send a quick action
  Future<void> sendQuickAction(String actionKey) async {
    final actionText = quickActions[actionKey];
    if (actionText != null) {
      await sendMessage(actionText);
    }
  }

  /// Update processing progress
  void updateProgress(int progress) {
    final processingMsg = state.processingMessage;
    if (processingMsg != null) {
      state = state.copyWith(
        processingMessage: processingMsg.copyWith(progress: progress),
      );
    }
  }

  /// Clear chat history
  void clearHistory() {
    state = state.copyWith(messages: []);
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  Future<void> _simulateAIResponse(String userMessage) async {
    // Create processing message
    final processingMsg = AIMessage.processing(
      'Processing your request...',
      progress: 0,
    );
    state = state.copyWith(processingMessage: processingMsg);

    // Simulate processing with progress updates
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(
        processingMessage: processingMsg.copyWith(
          content: _getProcessingMessage(userMessage, i),
          progress: i,
        ),
      );
    }

    // Generate response based on user message
    final response = _generateResponse(userMessage);

    state = state.copyWith(
      messages: [...state.messages, response],
      isProcessing: false,
      processingMessage: null,
    );
  }

  String _getProcessingMessage(String userMessage, int progress) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('caption')) {
      return 'Generating captions... $progress%';
    } else if (lowerMessage.contains('background')) {
      return 'Removing background... $progress%';
    } else if (lowerMessage.contains('silence') ||
        lowerMessage.contains('cut')) {
      return 'Detecting silence... $progress%';
    } else if (lowerMessage.contains('color') ||
        lowerMessage.contains('grade')) {
      return 'Applying color grading... $progress%';
    } else if (lowerMessage.contains('stabilize')) {
      return 'Stabilizing footage... $progress%';
    }
    return 'Processing... $progress%';
  }

  AIMessage _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('background')) {
      return AIMessage.ai(
        "Background removed. I've placed the isolated subject on a new track.",
        action: 'remove_background',
      );
    } else if (lowerMessage.contains('caption')) {
      return AIMessage.ai(
        "Captions added! I've transcribed your video and added English-style captions.",
        action: 'add_captions',
      );
    } else if (lowerMessage.contains('silence') ||
        lowerMessage.contains('cut')) {
      return AIMessage.ai(
        "Done! I've removed 12 silent segments totaling 45 seconds.",
        action: 'cut_silence',
      );
    } else if (lowerMessage.contains('color') ||
        lowerMessage.contains('grade')) {
      return AIMessage.ai(
        "Applied a cinematic color grade with enhanced contrast and teal-orange tones.",
        action: 'color_grade',
      );
    } else if (lowerMessage.contains('stabilize')) {
      return AIMessage.ai(
        "Video stabilized! Smoothed out the shaky footage while preserving motion.",
        action: 'stabilize',
      );
    } else if (lowerMessage.contains('speed')) {
      return AIMessage.ai(
        "What speed would you like? You can say 'slow motion' (0.5x), 'normal' (1x), or 'fast' (2x).",
        action: 'speed_prompt',
      );
    }

    return AIMessage.ai(
      "I understand you want to: $userMessage. Let me help you with that! What specific changes would you like me to make?",
    );
  }
}

/// AI Copilot provider
final aiCopilotProvider =
    StateNotifierProvider<AICopilotNotifier, AICopilotState>((ref) {
      return AICopilotNotifier();
    });

/// AI online status provider
final aiOnlineProvider = Provider<bool>((ref) {
  return ref.watch(aiCopilotProvider).isOnline;
});

/// AI processing status provider
final aiProcessingProvider = Provider<bool>((ref) {
  return ref.watch(aiCopilotProvider).isProcessing;
});
