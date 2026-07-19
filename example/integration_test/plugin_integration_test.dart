import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isSupported test', (WidgetTester tester) async {
    final bool support = await DynamicAppIcon.isSupported();
    expect(support, isNotNull);
  });
}
