/// AI Message model for VibeEdit AI
/// Represents chat messages in AI Copilot
library;

import 'package:flutter/foundation.dart';

/// Type of message sender
enum MessageSender { user, ai, system }

/// Status of AI processing
enum AIProcessingStatus { idle, processing, completed, failed }

/// A chat message in AI Copilot
@immutable
class AIMessage {
  const AIMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.status = AIProcessingStatus.completed,
    this.progress = 0,
    this.previewUrl,
    this.action,
    this.actionParams,
  });

  /// Unique message identifier
  final String id;

  /// Message sender
  final MessageSender sender;

  /// Message text content
  final String content;

  /// Message timestamp
  final DateTime timestamp;

  /// Processing status (for AI messages)
  final AIProcessingStatus status;

  /// Processing progress (0-100)
  final int progress;

  /// Preview thumbnail/video URL
  final String? previewUrl;

  /// Action performed (e.g., "remove_background", "add_captions")
  final String? action;

  /// Action parameters
  final Map<String, dynamic>? actionParams;

  /// Check if message is from user
  bool get isUser => sender == MessageSender.user;

  /// Check if message is from AI
  bool get isAI => sender == MessageSender.ai;

  /// Check if AI is currently processing
  bool get isProcessing => status == AIProcessingStatus.processing;

  /// Get formatted time string
  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Create a copy with modified fields
  AIMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    DateTime? timestamp,
    AIProcessingStatus? status,
    int? progress,
    String? previewUrl,
    String? action,
    Map<String, dynamic>? actionParams,
  }) {
    return AIMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      previewUrl: previewUrl ?? this.previewUrl,
      action: action ?? this.action,
      actionParams: actionParams ?? this.actionParams,
    );
  }

  /// Create a user message
  factory AIMessage.user(String content) {
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create an AI response message
  factory AIMessage.ai(
    String content, {
    String? previewUrl,
    String? action,
    Map<String, dynamic>? actionParams,
  }) {
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.ai,
      content: content,
      timestamp: DateTime.now(),
      previewUrl: previewUrl,
      action: action,
      actionParams: actionParams,
    );
  }

  /// Create a processing message
  factory AIMessage.processing(String content, {int progress = 0}) {
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.ai,
      content: content,
      timestamp: DateTime.now(),
      status: AIProcessingStatus.processing,
      progress: progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIMessage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
