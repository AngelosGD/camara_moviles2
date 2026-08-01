import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Member? _result;
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
    final result = await context.read<MemberProvider>().searchByName(query);
    if (!mounted) return;
    setState(() {
      _result = result;
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
                            _result = null;
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
            const SizedBox(height: 32),
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

    if (_result != null) {
      return _buildResultCard();
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

  Widget _buildResultCard() {
    final m = _result!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.accentPale,
              backgroundImage: m.fotoPath != null ? FileImage(File(m.fotoPath!)) : null,
              child: m.fotoPath == null
                  ? const Icon(Icons.person_outline, size: 36, color: AppTheme.textSecondary)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              '${m.nombre} ${m.apellidos}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (m.telefono != null)
              _infoRow(Icons.phone_outlined, m.telefono!),
            if (m.email != null)
              _infoRow(Icons.email_outlined, m.email!),
            const SizedBox(height: 4),
            _infoRow(
              Icons.calendar_today_outlined,
              'Registrado: ${m.fechaRegistro.day}/${m.fechaRegistro.month}/${m.fechaRegistro.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
