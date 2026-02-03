/// Media Picker screen for VibeEdit AI
/// Select videos and images from gallery or camera
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';

/// Media type enum
enum MediaType { video, image, audio }

/// Media picker bottom sheet
class MediaPickerSheet extends StatelessWidget {
  const MediaPickerSheet({
    super.key,
    this.mediaType = MediaType.video,
    this.onMediaSelected,
  });

  final MediaType mediaType;
  final void Function(File file)? onMediaSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.spacing20),

            // Title
            Text(_getTitle(), style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSizes.spacing24),

            // Options grid
            Row(
              children: [
                Expanded(
                  child: _PickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: AppColors.primary,
                    onTap: () => _pickFromGallery(context),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),
                if (mediaType == MediaType.video ||
                    mediaType == MediaType.image)
                  Expanded(
                    child: _PickerOption(
                      icon: mediaType == MediaType.video
                          ? Icons.videocam_rounded
                          : Icons.camera_alt_rounded,
                      label: mediaType == MediaType.video ? 'Record' : 'Camera',
                      color: AppColors.accent,
                      onTap: () => _captureMedia(context),
                    ),
                  ),
                if (mediaType != MediaType.image) ...[
                  const SizedBox(width: AppSizes.spacing16),
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.folder_rounded,
                      label: 'Files',
                      color: Color(0xFFEC4899),
                      onTap: () => _pickFromFiles(context),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSizes.spacing24),

            // Recent section
            if (mediaType == MediaType.video) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Videos', style: AppTextStyles.labelMedium),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _RecentMediaItem(onTap: () {});
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
            ],
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (mediaType) {
      case MediaType.video:
        return 'Add Video';
      case MediaType.image:
        return 'Add Image';
      case MediaType.audio:
        return 'Add Audio';
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    XFile? file;

    if (mediaType == MediaType.video) {
      file = await picker.pickVideo(source: ImageSource.gallery);
    } else if (mediaType == MediaType.image) {
      file = await picker.pickImage(source: ImageSource.gallery);
    }

    if (file != null && context.mounted) {
      Navigator.pop(context);
      onMediaSelected?.call(File(file.path));
    }
  }

  Future<void> _captureMedia(BuildContext context) async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final picker = ImagePicker();
    XFile? file;

    if (mediaType == MediaType.video) {
      file = await picker.pickVideo(source: ImageSource.camera);
    } else if (mediaType == MediaType.image) {
      file = await picker.pickImage(source: ImageSource.camera);
    }

    if (file != null && context.mounted) {
      Navigator.pop(context);
      onMediaSelected?.call(File(file.path));
    }
  }

  Future<void> _pickFromFiles(BuildContext context) async {
    FileType fileType;
    List<String>? extensions;

    switch (mediaType) {
      case MediaType.video:
        fileType = FileType.video;
        break;
      case MediaType.image:
        fileType = FileType.image;
        break;
      case MediaType.audio:
        fileType = FileType.audio;
        break;
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.path != null && context.mounted) {
      Navigator.pop(context);
      onMediaSelected?.call(File(result.files.single.path!));
    }
  }
}

/// Picker option button
class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent media thumbnail
class _RecentMediaItem extends StatelessWidget {
  const _RecentMediaItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Stack(
          children: [
            // Placeholder
            Center(
              child: Icon(
                Icons.movie_outlined,
                color: AppColors.textTertiary,
                size: 32,
              ),
            ),
            // Duration badge
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '0:30',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
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

/// Show media picker
Future<File?> showMediaPicker(
  BuildContext context, {
  MediaType mediaType = MediaType.video,
}) async {
  File? selectedFile;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => MediaPickerSheet(
      mediaType: mediaType,
      onMediaSelected: (file) => selectedFile = file,
    ),
  );

  return selectedFile;
}
