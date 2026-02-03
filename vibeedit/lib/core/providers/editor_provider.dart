/// Editor provider for VibeEdit AI
/// State management for video editor using Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';

/// Editor playback state
enum PlaybackState { idle, playing, paused, seeking }

/// State class for the video editor
class EditorState {
  const EditorState({
    this.project,
    this.currentTime = Duration.zero,
    this.playbackState = PlaybackState.idle,
    this.selectedClipId,
    this.selectedTrackId,
    this.zoom = 1.0,
    this.isExporting = false,
    this.exportProgress = 0,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  final Project? project;
  final Duration currentTime;
  final PlaybackState playbackState;
  final String? selectedClipId;
  final String? selectedTrackId;
  final double zoom;
  final bool isExporting;
  final int exportProgress;
  final List<Project> undoStack;
  final List<Project> redoStack;

  /// Check if playing
  bool get isPlaying => playbackState == PlaybackState.playing;

  /// Check if can undo
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if can redo
  bool get canRedo => redoStack.isNotEmpty;

  /// Get total duration
  Duration get totalDuration => project?.duration ?? Duration.zero;

  /// Get formatted current time
  String get formattedCurrentTime {
    final hours = currentTime.inHours;
    final minutes = currentTime.inMinutes.remainder(60);
    final seconds = currentTime.inSeconds.remainder(60);
    final frames = ((currentTime.inMilliseconds % 1000) / (1000 / 30)).round();

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${frames.toString().padLeft(2, '0')}';
  }

  /// Get formatted total time
  String get formattedTotalTime {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  EditorState copyWith({
    Project? project,
    Duration? currentTime,
    PlaybackState? playbackState,
    String? selectedClipId,
    String? selectedTrackId,
    double? zoom,
    bool? isExporting,
    int? exportProgress,
    List<Project>? undoStack,
    List<Project>? redoStack,
  }) {
    return EditorState(
      project: project ?? this.project,
      currentTime: currentTime ?? this.currentTime,
      playbackState: playbackState ?? this.playbackState,
      selectedClipId: selectedClipId ?? this.selectedClipId,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      zoom: zoom ?? this.zoom,
      isExporting: isExporting ?? this.isExporting,
      exportProgress: exportProgress ?? this.exportProgress,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

/// Editor state notifier
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(const EditorState());

  /// Load a project into the editor
  void loadProject(Project project) {
    state = EditorState(project: project);
  }

  /// Play/pause toggle
  void togglePlayback() {
    if (state.isPlaying) {
      state = state.copyWith(playbackState: PlaybackState.paused);
    } else {
      state = state.copyWith(playbackState: PlaybackState.playing);
    }
  }

  /// Seek to time
  void seekTo(Duration time) {
    final clampedTime = Duration(
      milliseconds: time.inMilliseconds.clamp(
        0,
        state.totalDuration.inMilliseconds,
      ),
    );
    state = state.copyWith(
      currentTime: clampedTime,
      playbackState: PlaybackState.seeking,
    );
  }

  /// Update current time (from video player)
  void updateCurrentTime(Duration time) {
    state = state.copyWith(currentTime: time);
  }

  /// Select a clip
  void selectClip(String? clipId, {String? trackId}) {
    state = state.copyWith(selectedClipId: clipId, selectedTrackId: trackId);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedClipId: null, selectedTrackId: null);
  }

  /// Add clip to track
  void addClip(String trackId, Clip clip) {
    final project = state.project;
    if (project == null) return;

    _saveUndoState();

    final updatedTracks = project.tracks.map((track) {
      if (track.id == trackId) {
        return track.addClip(clip);
      }
      return track;
    }).toList();

    final newDuration = _calculateDuration(updatedTracks);
    final updatedProject = project.copyWith(
      tracks: updatedTracks,
      duration: newDuration,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(project: updatedProject, redoStack: []);
  }

  /// Remove selected clip
  void removeSelectedClip() {
    final clipId = state.selectedClipId;
    final trackId = state.selectedTrackId;
    if (clipId == null || trackId == null) return;

    final project = state.project;
    if (project == null) return;

    _saveUndoState();

    final updatedTracks = project.tracks.map((track) {
      if (track.id == trackId) {
        return track.removeClip(clipId);
      }
      return track;
    }).toList();

    final newDuration = _calculateDuration(updatedTracks);
    final updatedProject = project.copyWith(
      tracks: updatedTracks,
      duration: newDuration,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      project: updatedProject,
      selectedClipId: null,
      selectedTrackId: null,
      redoStack: [],
    );
  }

  /// Split clip at current time
  void splitAtPlayhead() {
    final clipId = state.selectedClipId;
    final trackId = state.selectedTrackId;
    final currentTime = state.currentTime;
    if (clipId == null || trackId == null) return;

    final project = state.project;
    if (project == null) return;

    // Find the clip and track
    Track? targetTrack;
    Clip? targetClip;
    for (final track in project.tracks) {
      if (track.id == trackId) {
        targetTrack = track;
        for (final clip in track.clips) {
          if (clip.id == clipId) {
            targetClip = clip;
            break;
          }
        }
        break;
      }
    }

    if (targetTrack == null || targetClip == null) return;

    // Check if playhead is within clip
    if (currentTime <= targetClip.startTime ||
        currentTime >= targetClip.endTime) {
      return;
    }

    _saveUndoState();

    // Create two clips from the split
    final firstDuration = currentTime - targetClip.startTime;
    final secondDuration = targetClip.endTime - currentTime;

    final firstClip = targetClip.copyWith(duration: firstDuration);

    final secondClip = targetClip.copyWith(
      id: '${targetClip.id}_split',
      startTime: currentTime,
      duration: secondDuration,
      sourceStartTime: targetClip.sourceStartTime + firstDuration,
    );

    // Update clips list
    final updatedClips = targetTrack.clips.where((c) => c.id != clipId).toList()
      ..add(firstClip)
      ..add(secondClip);

    final updatedTrack = targetTrack.copyWith(clips: updatedClips);
    final updatedTracks = project.tracks.map((t) {
      return t.id == trackId ? updatedTrack : t;
    }).toList();

    final updatedProject = project.copyWith(
      tracks: updatedTracks,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(project: updatedProject, redoStack: []);
  }

  /// Undo last action
  void undo() {
    if (state.undoStack.isEmpty) return;

    final previousState = state.undoStack.last;
    final newUndoStack = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedoStack = state.project != null
        ? [...state.redoStack, state.project!]
        : state.redoStack;

    state = state.copyWith(
      project: previousState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Redo last undone action
  void redo() {
    if (state.redoStack.isEmpty) return;

    final nextState = state.redoStack.last;
    final newRedoStack = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndoStack = state.project != null
        ? [...state.undoStack, state.project!]
        : state.undoStack;

    state = state.copyWith(
      project: nextState,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Set zoom level
  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.5, 4.0));
  }

  /// Skip to start
  void skipToStart() {
    state = state.copyWith(currentTime: Duration.zero);
  }

  /// Skip to end
  void skipToEnd() {
    state = state.copyWith(currentTime: state.totalDuration);
  }

  /// Start export
  void startExport() {
    state = state.copyWith(isExporting: true, exportProgress: 0);
  }

  /// Update export progress
  void updateExportProgress(int progress) {
    state = state.copyWith(exportProgress: progress);
  }

  /// Finish export
  void finishExport(String? outputPath) {
    final project = state.project;
    if (project != null && outputPath != null) {
      state = state.copyWith(
        project: project.copyWith(
          outputPath: outputPath,
          status: ProjectStatus.completed,
        ),
        isExporting: false,
        exportProgress: 100,
      );
    } else {
      state = state.copyWith(isExporting: false);
    }
  }

  void _saveUndoState() {
    final project = state.project;
    if (project != null) {
      state = state.copyWith(undoStack: [...state.undoStack, project]);
    }
  }

  Duration _calculateDuration(List<Track> tracks) {
    Duration maxDuration = Duration.zero;
    for (final track in tracks) {
      if (track.duration > maxDuration) {
        maxDuration = track.duration;
      }
    }
    return maxDuration;
  }
}

/// Editor provider
final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((
  ref,
) {
  return EditorNotifier();
});

/// Selected clip provider
final selectedClipProvider = Provider<Clip?>((ref) {
  final editorState = ref.watch(editorProvider);
  final project = editorState.project;
  final clipId = editorState.selectedClipId;
  final trackId = editorState.selectedTrackId;

  if (project == null || clipId == null || trackId == null) return null;

  for (final track in project.tracks) {
    if (track.id == trackId) {
      for (final clip in track.clips) {
        if (clip.id == clipId) {
          return clip;
        }
      }
    }
  }
  return null;
});
