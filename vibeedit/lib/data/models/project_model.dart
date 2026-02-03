/// Project model for VibeEdit AI
/// Represents a video editing project with metadata
library;

import 'package:flutter/foundation.dart';

import 'track_model.dart';

/// Status of a project
enum ProjectStatus { draft, processing, completed, failed }

/// Video editing project
@immutable
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailPath,
    this.duration = Duration.zero,
    this.status = ProjectStatus.draft,
    this.tracks = const [],
    this.aspectRatio = 9 / 16,
    this.outputPath,
  });

  /// Unique project identifier
  final String id;

  /// Project name/title
  final String name;

  /// Thumbnail image path
  final String? thumbnailPath;

  /// Total project duration
  final Duration duration;

  /// Project creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Current project status
  final ProjectStatus status;

  /// List of tracks (video, audio, text)
  final List<Track> tracks;

  /// Aspect ratio (9:16 for reels, 16:9 for landscape, 1:1 for square)
  final double aspectRatio;

  /// Exported video path (if completed)
  final String? outputPath;

  /// Check if project is a draft
  bool get isDraft => status == ProjectStatus.draft;

  /// Get formatted duration string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get relative time since last edit
  String get editedAgo {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get video tracks only
  List<Track> get videoTracks =>
      tracks.where((t) => t.type == TrackType.video).toList();

  /// Get audio tracks only
  List<Track> get audioTracks =>
      tracks.where((t) => t.type == TrackType.audio).toList();

  /// Get text/overlay tracks only
  List<Track> get textTracks =>
      tracks.where((t) => t.type == TrackType.text).toList();

  /// Create a copy with modified fields
  Project copyWith({
    String? id,
    String? name,
    String? thumbnailPath,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectStatus? status,
    List<Track>? tracks,
    double? aspectRatio,
    String? outputPath,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      outputPath: outputPath ?? this.outputPath,
    );
  }

  /// Create a new empty project
  factory Project.create({required String name}) {
    final now = DateTime.now();
    return Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
      tracks: [
        Track.create(type: TrackType.video, name: 'Video 1'),
        Track.create(type: TrackType.audio, name: 'Audio 1'),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
