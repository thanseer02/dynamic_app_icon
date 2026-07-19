import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_app_icon/src/method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDynamicAppIcon platform = MethodChannelDynamicAppIcon();
  const MethodChannel channel = MethodChannel('dynamic_app_icon');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isSupported':
            return true;
          case 'setIcon':
            return null;
          case 'getCurrentIcon':
            return 'dark_icon';
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('isSupported returns correct status', () async {
    expect(await platform.isSupported(), true);
  });

  test('setIcon invokes channel without error', () async {
    expect(platform.setIcon(iconName: 'dark_icon'), completes);
  });

  test('getCurrentIcon returns active name', () async {
    expect(await platform.getCurrentIcon(), 'dark_icon');
  });
}
