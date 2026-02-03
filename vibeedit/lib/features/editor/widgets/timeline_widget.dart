/// Timeline widget for VibeEdit AI
/// Multi-track timeline with clips
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

/// Timeline with tracks and playhead
class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.tracks,
    required this.currentTime,
    required this.totalDuration,
    required this.zoom,
    this.onSeek,
    this.onClipTap,
    this.selectedClipId,
  });

  final List<Track> tracks;
  final Duration currentTime;
  final Duration totalDuration;
  final double zoom;
  final ValueChanged<Duration>? onSeek;
  final void Function(String clipId, String trackId)? onClipTap;
  final String? selectedClipId;

  double get _pixelsPerSecond => 30.0 * zoom;

  double get _timelineWidth {
    final duration = totalDuration.inSeconds > 0
        ? totalDuration.inSeconds
        : 120;
    return duration * _pixelsPerSecond;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.timelineHeight,
      decoration: BoxDecoration(gradient: AppColors.timelineGradient),
      child: Row(
        children: [
          // Track headers sidebar
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.panelBackground,
              border: Border(
                right: BorderSide(color: AppColors.panelBorder, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header space for time ruler
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.panelBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.layers_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                // Track type icons
                Expanded(
                  child: Column(
                    children: [
                      // Video tracks
                      for (final _ in tracks.where(
                        (t) => t.type == TrackType.video,
                      ))
                        _TrackHeader(
                          icon: Icons.videocam_rounded,
                          color: AppColors.videoTrack,
                          height: AppSizes.trackHeight + 4,
                        ),
                      // Text tracks
                      for (final _ in tracks.where(
                        (t) => t.type == TrackType.text,
                      ))
                        _TrackHeader(
                          icon: Icons.text_fields_rounded,
                          color: AppColors.textTrack,
                          height: 36,
                        ),
                      // Audio tracks
                      for (final _ in tracks.where(
                        (t) => t.type == TrackType.audio,
                      ))
                        _TrackHeader(
                          icon: Icons.audiotrack_rounded,
                          color: AppColors.audioTrack,
                          height: 44,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline content
          Expanded(
            child: Column(
              children: [
                // Time ruler
                _TimeRuler(
                  totalDuration: totalDuration,
                  pixelsPerSecond: _pixelsPerSecond,
                  width: _timelineWidth,
                ),

                // Tracks
                Expanded(
                  child: Stack(
                    children: [
                      // Tracks scroll view
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: _timelineWidth,
                          child: Column(
                            children: [
                              // Video tracks
                              for (final track in tracks.where(
                                (t) => t.type == TrackType.video,
                              ))
                                _TrackRow(
                                  track: track,
                                  pixelsPerSecond: _pixelsPerSecond,
                                  onClipTap: (clipId) =>
                                      onClipTap?.call(clipId, track.id),
                                  selectedClipId: selectedClipId,
                                ),

                              // Text tracks
                              for (final track in tracks.where(
                                (t) => t.type == TrackType.text,
                              ))
                                _TextTrackRow(
                                  track: track,
                                  pixelsPerSecond: _pixelsPerSecond,
                                  onClipTap: (clipId) =>
                                      onClipTap?.call(clipId, track.id),
                                  selectedClipId: selectedClipId,
                                ),

                              // Audio tracks
                              for (final track in tracks.where(
                                (t) => t.type == TrackType.audio,
                              ))
                                _AudioTrackRow(
                                  track: track,
                                  pixelsPerSecond: _pixelsPerSecond,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Playhead with neon glow
                      Positioned(
                        left:
                            currentTime.inMilliseconds /
                            1000 *
                            _pixelsPerSecond,
                        top: 0,
                        bottom: 0,
                        child: _Playhead(),
                      ),
                    ],
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

/// Track header with icon
class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    required this.icon,
    required this.color,
    required this.height,
  });

  final IconData icon;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.panelBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _TimeRuler extends StatelessWidget {
  const _TimeRuler({
    required this.totalDuration,
    required this.pixelsPerSecond,
    required this.width,
  });

  final Duration totalDuration;
  final double pixelsPerSecond;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: width,
      color: AppColors.surface,
      child: CustomPaint(
        painter: _TimeRulerPainter(
          pixelsPerSecond: pixelsPerSecond,
          totalSeconds: totalDuration.inSeconds > 0
              ? totalDuration.inSeconds
              : 120,
        ),
      ),
    );
  }
}

class _TimeRulerPainter extends CustomPainter {
  _TimeRulerPainter({
    required this.pixelsPerSecond,
    required this.totalSeconds,
  });

  final double pixelsPerSecond;
  final int totalSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textTertiary
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw time marks every 15 seconds
    for (int i = 0; i <= totalSeconds; i += 15) {
      final x = i * pixelsPerSecond;

      // Draw tick
      canvas.drawLine(
        Offset(x, size.height - 8),
        Offset(x, size.height),
        paint,
      );

      // Draw time label
      final minutes = i ~/ 60;
      final seconds = i % 60;
      final label =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      textPainter.text = TextSpan(
        text: label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 4, 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.pixelsPerSecond,
    required this.onClipTap,
    this.selectedClipId,
  });

  final Track track;
  final double pixelsPerSecond;
  final ValueChanged<String> onClipTap;
  final String? selectedClipId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.trackHeight,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          // Track background
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Clips
          for (final clip in track.clips)
            Positioned(
              left: clip.startTime.inMilliseconds / 1000 * pixelsPerSecond,
              width: clip.duration.inMilliseconds / 1000 * pixelsPerSecond,
              top: 4,
              bottom: 4,
              child: _ClipWidget(
                clip: clip,
                isSelected: clip.id == selectedClipId,
                onTap: () => onClipTap(clip.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClipWidget extends StatelessWidget {
  const _ClipWidget({
    required this.clip,
    required this.isSelected,
    required this.onTap,
  });

  final Clip clip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: ui.Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail placeholder
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.accent.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // Clip label
            if (clip.name != null)
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    clip.name!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 9,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextTrackRow extends StatelessWidget {
  const _TextTrackRow({
    required this.track,
    required this.pixelsPerSecond,
    required this.onClipTap,
    this.selectedClipId,
  });

  final Track track;
  final double pixelsPerSecond;
  final ValueChanged<String> onClipTap;
  final String? selectedClipId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          for (final clip in track.clips)
            Positioned(
              left: clip.startTime.inMilliseconds / 1000 * pixelsPerSecond,
              width: clip.duration.inMilliseconds / 1000 * pixelsPerSecond,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => onClipTap(clip.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: clip.id == selectedClipId
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    clip.text ?? 'Title',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudioTrackRow extends StatelessWidget {
  const _AudioTrackRow({required this.track, required this.pixelsPerSecond});

  final Track track;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          // Waveform placeholder
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              painter: _WaveformPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final random = [0.3, 0.5, 0.8, 0.4, 0.7, 0.2, 0.6, 0.9, 0.3, 0.5];
    final barWidth = 3.0;
    final spacing = 4.0;

    for (int i = 0; i < size.width / (barWidth + spacing); i++) {
      final height = size.height * 0.8 * random[i % random.length];
      final x = i * (barWidth + spacing);
      final y = (size.height - height) / 2;

      canvas.drawLine(Offset(x, y), Offset(x, y + height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Playhead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Stack(
        clipBehavior: ui.Clip.none,
        children: [
          // Glow effect
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.playhead,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.playheadGlow,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.playhead.withValues(alpha: 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Playhead line
          Positioned(
            left: 7,
            top: 0,
            bottom: 0,
            child: Container(width: 2, color: AppColors.playhead),
          ),
          // Playhead handle (triangle)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.playhead,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.playheadGlow, blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
