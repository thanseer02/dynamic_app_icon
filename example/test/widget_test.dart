// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dynamic_app_icon_example/main.dart';

void main() {
  testWidgets('Verify App Launch', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DynamicAppIconDemo());

    // Verify that the title text is rendered.
    expect(find.text('Dynamic App Icon Demo'), findsOneWidget);
  });
}
