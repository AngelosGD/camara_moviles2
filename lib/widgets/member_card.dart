import 'dart:io';

import 'package:flutter/material.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String get _fullName => '${member.nombre} ${member.apellidos}';

  String get _formattedDate {
    final d = member.fechaRegistro;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.accentPale,
          backgroundImage: member.fotoPath != null
              ? FileImage(File(member.fotoPath!))
              : null,
          child: member.fotoPath == null
              ? const Icon(Icons.person_outline, color: AppTheme.textSecondary)
              : null,
        ),
        title: Text(
          _fullName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          'Registrado: $_formattedDate',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppTheme.textSecondary,
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.textSecondary,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}