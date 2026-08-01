import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/member_provider.dart';
import '../widgets/member_card.dart';
import '../widgets/empty_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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
                itemBuilder: (_, i) => MemberCard(member: members[i]),
              ),
            ),
    );
  }
}
