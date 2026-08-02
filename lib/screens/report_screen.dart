import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/member_card.dart';
import '../widgets/empty_state.dart';
import 'member_form_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<void> _openEdit(BuildContext context, Member member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)),
    );
  }

  void _confirmDelete(BuildContext context, Member member) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Seguro que deseas eliminar a ${member.nombre} ${member.apellidos}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        await context.read<MemberProvider>().deleteMember(member.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberProvider>();
    final members = provider.members;

    return Scaffold(
      appBar: AppBar(title: const Text('Todos los Miembros')),
      body: members.isEmpty
          ? const EmptyState(
              icon: Icons.people_outline,
              title: 'Aún no hay miembros registrados',
              subtitle: 'Usa la pestaña Registrar para añadir el primero',
            )
          : RefreshIndicator(
              onRefresh: () => context.read<MemberProvider>().loadMembers(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: members.length,
                itemBuilder: (_, i) => MemberCard(
                  member: members[i],
                  onEdit: () => _openEdit(context, members[i]),
                  onDelete: () => _confirmDelete(context, members[i]),
                ),
              ),
            ),
    );
  }
}