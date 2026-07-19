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
          case 'changeIcon':
            return null;
          case 'resetIcon':
            return null;
          case 'currentIcon':
            return 'dark_icon';
          case 'availableIcons':
            return ['default', 'dark_icon', 'festive_icon'];
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

  test('changeIcon invokes channel correctly', () async {
    expect(platform.change(iconName: 'dark_icon'), completes);
  });

  test('resetIcon invokes channel correctly', () async {
    expect(platform.reset(), completes);
  });

  test('currentIcon returns correct status', () async {
    expect(await platform.current(), 'dark_icon');
  });

  test('availableIcons returns list of configured icons', () async {
    expect(await platform.availableIcons(), ['default', 'dark_icon', 'festive_icon']);
  });
}
