import 'package:flutter_test/flutter_test.dart';

import 'package:camara_moviles2/app.dart';
import 'package:camara_moviles2/data/mock_member_repository.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(App(repository: MockMemberRepository()));
    await tester.pump();
    expect(find.text('Registrar Miembro'), findsOneWidget);
  });
}
