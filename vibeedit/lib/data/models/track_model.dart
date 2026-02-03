/// Track model for VibeEdit AI
/// Represents a timeline track containing clips
library;

import 'package:flutter/foundation.dart';

import 'clip_model.dart';

/// Type of track
enum TrackType { video, audio, text }

/// A timeline track containing clips
@immutable
class Track {
  const Track({
    required this.id,
    required this.type,
    required this.name,
    this.clips = const [],
    this.isLocked = false,
    this.isVisible = true,
    this.isMuted = false,
  });

  /// Unique track identifier
  final String id;

  /// Type of track
  final TrackType type;

  /// Track name
  final String name;

  /// List of clips on this track
  final List<Clip> clips;

  /// Whether track is locked for editing
  final bool isLocked;

  /// Whether track is visible (video/text only)
  final bool isVisible;

  /// Whether track audio is muted
  final bool isMuted;

  /// Get total track duration
  Duration get duration {
    if (clips.isEmpty) return Duration.zero;
    Duration maxEnd = Duration.zero;
    for (final clip in clips) {
      if (clip.endTime > maxEnd) {
        maxEnd = clip.endTime;
      }
    }
    return maxEnd;
  }

  /// Check if track has any clips
  bool get hasClips => clips.isNotEmpty;

  /// Get clip at specific time
  Clip? getClipAt(Duration time) {
    for (final clip in clips) {
      if (time >= clip.startTime && time < clip.endTime) {
        return clip;
      }
    }
    return null;
  }

  /// Create a copy with modified fields
  Track copyWith({
    String? id,
    TrackType? type,
    String? name,
    List<Clip>? clips,
    bool? isLocked,
    bool? isVisible,
    bool? isMuted,
  }) {
    return Track(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      clips: clips ?? this.clips,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  /// Add a clip to the track
  Track addClip(Clip clip) {
    return copyWith(clips: [...clips, clip]);
  }

  /// Remove a clip from the track
  Track removeClip(String clipId) {
    return copyWith(clips: clips.where((c) => c.id != clipId).toList());
  }

  /// Update a clip in the track
  Track updateClip(Clip updatedClip) {
    return copyWith(
      clips: clips
          .map((c) => c.id == updatedClip.id ? updatedClip : c)
          .toList(),
    );
  }

  /// Create a new empty track
  factory Track.create({required TrackType type, required String name}) {
    return Track(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      name: name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
