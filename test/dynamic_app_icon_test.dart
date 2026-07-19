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
  Future<void> setIcon({required String iconName}) => Future.value();

  @override
  Future<String?> getCurrentIcon() => Future.value('dark_icon');
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

  test('setIcon calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(DynamicAppIcon.setIcon('dark_icon'), completes);
  });

  test('getCurrentIcon calls platform signature', () async {
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(await DynamicAppIcon.getCurrentIcon(), 'dark_icon');
  });
}
