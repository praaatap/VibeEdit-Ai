/// Clip model for VibeEdit AI
/// Represents a media clip on the timeline
library;

import 'package:flutter/foundation.dart';

/// Type of media clip
enum ClipType { video, audio, image, text }

/// A media clip on the timeline
@immutable
class Clip {
  const Clip({
    required this.id,
    required this.type,
    required this.sourcePath,
    required this.startTime,
    required this.duration,
    this.sourceStartTime = Duration.zero,
    this.thumbnailPath,
    this.name,
    this.speed = 1.0,
    this.volume = 1.0,
    this.isMuted = false,
    this.filters = const [],
    this.text,
    this.textStyle,
  });

  /// Unique clip identifier
  final String id;

  /// Type of clip
  final ClipType type;

  /// Path to source media file
  final String sourcePath;

  /// Start time on timeline
  final Duration startTime;

  /// Duration of clip on timeline
  final Duration duration;

  /// Start time in source file (for trimmed clips)
  final Duration sourceStartTime;

  /// Thumbnail image path
  final String? thumbnailPath;

  /// Optional clip name
  final String? name;

  /// Playback speed (1.0 = normal)
  final double speed;

  /// Audio volume (0.0 - 1.0)
  final double volume;

  /// Whether audio is muted
  final bool isMuted;

  /// Applied filters/effects
  final List<String> filters;

  /// Text content (for text clips)
  final String? text;

  /// Text style preset (for text clips)
  final String? textStyle;

  /// End time on timeline
  Duration get endTime => startTime + duration;

  /// Actual duration considering speed
  Duration get actualDuration =>
      Duration(milliseconds: (duration.inMilliseconds / speed).round());

  /// Check if clip is a video clip
  bool get isVideo => type == ClipType.video;

  /// Check if clip is an audio clip
  bool get isAudio => type == ClipType.audio;

  /// Check if clip is a text overlay
  bool get isText => type == ClipType.text;

  /// Get formatted duration string
  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create a copy with modified fields
  Clip copyWith({
    String? id,
    ClipType? type,
    String? sourcePath,
    Duration? startTime,
    Duration? duration,
    Duration? sourceStartTime,
    String? thumbnailPath,
    String? name,
    double? speed,
    double? volume,
    bool? isMuted,
    List<String>? filters,
    String? text,
    String? textStyle,
  }) {
    return Clip(
      id: id ?? this.id,
      type: type ?? this.type,
      sourcePath: sourcePath ?? this.sourcePath,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      sourceStartTime: sourceStartTime ?? this.sourceStartTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      name: name ?? this.name,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      filters: filters ?? this.filters,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Create a new clip from video file
  factory Clip.fromVideo({
    required String sourcePath,
    required Duration duration,
    String? thumbnailPath,
    String? name,
  }) {
    return Clip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ClipType.video,
      sourcePath: sourcePath,
      startTime: Duration.zero,
      duration: duration,
      thumbnailPath: thumbnailPath,
      name: name,
    );
  }

  /// Create a text overlay clip
  factory Clip.text({
    required String text,
    required Duration startTime,
    Duration duration = const Duration(seconds: 3),
    String? textStyle,
  }) {
    return Clip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ClipType.text,
      sourcePath: '',
      startTime: startTime,
      duration: duration,
      text: text,
      textStyle: textStyle ?? 'default',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clip && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
