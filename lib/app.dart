import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/member_repository.dart';
import 'providers/member_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  final MemberRepository? repository;

  const App({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberProvider(repository ?? SQLiteMemberRepository())
        ..loadMembers(),
      child: MaterialApp(
        title: 'Club Miembros',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
