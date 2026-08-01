import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoPickerWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;

  const PhotoPickerWidget({
    super.key,
    this.imagePath,
    required this.onTakePhoto,
    required this.onPickFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppTheme.accentPale,
          backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
          child: imagePath == null
              ? const Icon(Icons.person_outline, size: 48, color: AppTheme.textSecondary)
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              label: const Text('Tomar Foto'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onPickFromGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Galería'),
            ),
          ],
        ),
      ],
    );
  }
}
