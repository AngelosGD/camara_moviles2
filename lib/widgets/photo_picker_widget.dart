import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoPickerWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTakePhoto;

  const PhotoPickerWidget({
    super.key,
    this.imagePath,
    required this.onTakePhoto,
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
        OutlinedButton.icon(
          onPressed: onTakePhoto,
          icon: const Icon(Icons.camera_alt_outlined, size: 20),
          label: const Text('Tomar Foto'),
        ),
      ],
    );
  }
}
