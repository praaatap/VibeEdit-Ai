/// Audio Mixer Panel for VibeEdit AI
/// Volume control, fade in/out, add music
library;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/constants.dart';

/// Audio track model
class AudioTrackMix {
  AudioTrackMix({
    required this.id,
    required this.name,
    required this.icon,
    this.volume = 1.0,
    this.isMuted = false,
    this.fadeIn = Duration.zero,
    this.fadeOut = Duration.zero,
  });

  final String id;
  final String name;
  final IconData icon;
  double volume;
  bool isMuted;
  Duration fadeIn;
  Duration fadeOut;
}

/// Audio Mixer Panel
class AudioMixerPanel extends StatefulWidget {
  const AudioMixerPanel({
    super.key,
    this.onVolumeChanged,
    this.onAddMusic,
    this.onClose,
  });

  final void Function(String trackId, double volume)? onVolumeChanged;
  final VoidCallback? onAddMusic;
  final VoidCallback? onClose;

  @override
  State<AudioMixerPanel> createState() => _AudioMixerPanelState();
}

class _AudioMixerPanelState extends State<AudioMixerPanel> {
  final List<AudioTrackMix> _tracks = [
    AudioTrackMix(
      id: 'video',
      name: 'Video Audio',
      icon: Icons.videocam_rounded,
    ),
    AudioTrackMix(
      id: 'music',
      name: 'Music',
      icon: Icons.music_note_rounded,
      volume: 0.7,
    ),
    AudioTrackMix(
      id: 'voiceover',
      name: 'Voice Over',
      icon: Icons.mic_rounded,
      volume: 0.0,
    ),
  ];

  double _masterVolume = 1.0;

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

          // Master volume
          _buildMasterVolume(),

          // Track list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                return _AudioTrackRow(
                  track: _tracks[index],
                  onVolumeChanged: (v) {
                    setState(() => _tracks[index].volume = v);
                    widget.onVolumeChanged?.call(_tracks[index].id, v);
                  },
                  onMuteToggled: () {
                    setState(
                      () => _tracks[index].isMuted = !_tracks[index].isMuted,
                    );
                  },
                );
              },
            ),
          ),

          // Add music button
          _buildAddMusicButton(),
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
          Icon(Icons.volume_up_rounded, color: AppColors.audioTrack),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Audio Mixer',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterVolume() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Icon(Icons.speaker_rounded, size: 20, color: AppColors.audioTrack),
          const SizedBox(width: AppSizes.spacing12),
          Text(
            'Master',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.audioTrack,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.audioTrack,
              ),
              child: Slider(
                value: _masterVolume,
                onChanged: (v) => setState(() => _masterVolume = v),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              '${(_masterVolume * 100).toInt()}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMusicButton() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: widget.onAddMusic,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Music'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.audioTrack,
            side: BorderSide(color: AppColors.audioTrack),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _AudioTrackRow extends StatelessWidget {
  const _AudioTrackRow({
    required this.track,
    required this.onVolumeChanged,
    required this.onMuteToggled,
  });

  final AudioTrackMix track;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      padding: const EdgeInsets.all(AppSizes.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: [
          // Mute button
          GestureDetector(
            onTap: onMuteToggled,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: track.isMuted
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                track.isMuted ? Icons.volume_off : track.icon,
                size: 18,
                color: track.isMuted ? AppColors.error : AppColors.audioTrack,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),

          // Track name
          SizedBox(
            width: 80,
            child: Text(
              track.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: track.isMuted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Volume slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: track.isMuted
                    ? AppColors.textTertiary
                    : AppColors.audioTrack,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: track.isMuted
                    ? AppColors.textTertiary
                    : AppColors.audioTrack,
                trackHeight: 3,
              ),
              child: Slider(
                value: track.volume,
                onChanged: track.isMuted ? null : onVolumeChanged,
              ),
            ),
          ),

          // Volume percentage
          SizedBox(
            width: 40,
            child: Text(
              '${(track.volume * 100).toInt()}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: track.isMuted
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
