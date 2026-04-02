import 'package:flutter_test/flutter_test.dart';

import 'package:aegis_intelligence/main.dart';

void main() {
  testWidgets('AEGIS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AegisApp());

    // Verify the app bar title is present.
    expect(find.text('AEGIS INTELLIGENCE'), findsOneWidget);
  });
}
