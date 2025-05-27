// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:cremorapp/main.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CremorApp());

    // Verify that the login view is displayed.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
