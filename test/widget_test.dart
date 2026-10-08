import 'package:flutter_test/flutter_test.dart';
import 'package:app5/main.dart';

void main() {
  testWidgets('Module V app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ModuleVApp());
    expect(find.text('Module V: Data Persistence'), findsOneWidget);
  });
}
