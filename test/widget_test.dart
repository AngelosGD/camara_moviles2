import 'package:flutter_test/flutter_test.dart';
import 'package:camara_moviles2/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Registrar Miembro'), findsOneWidget);
  });
}
