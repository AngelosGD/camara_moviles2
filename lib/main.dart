import 'package:flutter/material.dart';

import 'app.dart';
import 'data/member_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App(repository: SQLiteMemberRepository()));
}
