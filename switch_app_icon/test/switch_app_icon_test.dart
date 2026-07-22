import 'package:flutter_test/flutter_test.dart';
import 'package:switch_app_icon/switch_app_icon.dart';
import 'package:switch_app_icon/src/interface.dart';
import 'package:switch_app_icon/src/method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSwitchAppIconPlatform
    with MockPlatformInterfaceMixin
    implements SwitchAppIconPlatform {

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
  final SwitchAppIconPlatform initialPlatform = SwitchAppIconPlatform.instance;

  test('$MethodChannelSwitchAppIcon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSwitchAppIcon>());
  });

  test('isSupported calls platform signature', () async {
    MockSwitchAppIconPlatform fakePlatform = MockSwitchAppIconPlatform();
    SwitchAppIconPlatform.instance = fakePlatform;

    expect(await SwitchAppIcon.isSupported(), true);
  });

  test('change calls platform signature', () async {
    MockSwitchAppIconPlatform fakePlatform = MockSwitchAppIconPlatform();
    SwitchAppIconPlatform.instance = fakePlatform;

    expect(SwitchAppIcon.change('dark_icon'), completes);
  });

  test('reset calls platform signature', () async {
    MockSwitchAppIconPlatform fakePlatform = MockSwitchAppIconPlatform();
    SwitchAppIconPlatform.instance = fakePlatform;

    expect(SwitchAppIcon.reset(), completes);
  });

  test('current calls platform signature', () async {
    MockSwitchAppIconPlatform fakePlatform = MockSwitchAppIconPlatform();
    SwitchAppIconPlatform.instance = fakePlatform;

    expect(await SwitchAppIcon.current(), 'dark_icon');
  });

  test('availableIcons calls platform signature', () async {
    MockSwitchAppIconPlatform fakePlatform = MockSwitchAppIconPlatform();
    SwitchAppIconPlatform.instance = fakePlatform;

    expect(await SwitchAppIcon.availableIcons(), ['default', 'dark_icon', 'festive_icon']);
  });
}
