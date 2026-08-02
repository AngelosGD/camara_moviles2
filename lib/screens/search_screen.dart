import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/member_card.dart';
import 'member_form_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Member> _results = <Member>[];
  bool _isSearching = false;
  bool _searched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
      _searched = true;
    });
    final results = await context.read<MemberProvider>().searchMembers(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Miembro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nombre a buscar',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = <Member>[];
                            _searched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _onSearch(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _onSearch,
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('BUSCAR'),
              ),
            ),
            const SizedBox(height: 16),
            if (_searched && _results.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_results.length} ${_results.length == 1 ? 'resultado' : 'resultados'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isNotEmpty) {
      return ListView.builder(
        itemCount: _results.length,
        itemBuilder: (_, i) => _MemberCardActions(member: _results[i]),
      );
    }

    if (_searched) {
      return const EmptyState(
        icon: Icons.person_off_outlined,
        title: 'No se encontró miembro',
        subtitle: 'Verifica el nombre e inténtalo de nuevo',
      );
    }

    return const EmptyState(
      icon: Icons.search_off_outlined,
      title: 'Busca un miembro',
      subtitle: 'Ingresa el nombre y presiona buscar',
    );
  }
}

class _MemberCardActions extends StatelessWidget {
  final Member member;

  const _MemberCardActions({required this.member});

  Future<void> _openEdit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)),
    );
  }

  void _confirmDelete(BuildContext context) {
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
    return MemberCard(
      member: member,
      onEdit: () => _openEdit(context),
      onDelete: () => _confirmDelete(context),
    );
  }
}
