import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';
import 'package:dynamic_app_icon/src/interface.dart';
import 'package:dynamic_app_icon/src/method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDynamicAppIconPlatform
    with MockPlatformInterfaceMixin
    implements DynamicAppIconPlatform {

  @override
  Future<bool> isSupported() => Future.value(true);

  @override
  Future<void> change({required String iconName}) => Future.value();

  @override
  Future<void> reset() => Future.value();

  @override
  Future<String?> current() => Future.value('dark_icon');

  @override
  Future<List<String>> availableIcons() => Future.value(['default', 'dark_icon', 'festive_icon']);
}

void main() {
  final DynamicAppIconPlatform initialPlatform = DynamicAppIconPlatform.instance;

  test('$MethodChannelDynamicAppIcon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDynamicAppIcon>());
  });

  test('isSupported calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(await DynamicAppIcon.isSupported(), true);
  });

  test('change calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(DynamicAppIcon.change('dark_icon'), completes);
  });

  test('reset calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(DynamicAppIcon.reset(), completes);
  });

  test('current calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(await DynamicAppIcon.current(), 'dark_icon');
  });

  test('availableIcons calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(await DynamicAppIcon.availableIcons(), ['default', 'dark_icon', 'festive_icon']);
  });
}
