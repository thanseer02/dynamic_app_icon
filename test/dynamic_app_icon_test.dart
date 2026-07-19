import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_app_icon/dynamic_app_icon.dart';
import 'package:dynamic_app_icon/dynamic_app_icon_platform_interface.dart';
import 'package:dynamic_app_icon/dynamic_app_icon_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDynamicAppIconPlatform
    with MockPlatformInterfaceMixin
    implements DynamicAppIconPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DynamicAppIconPlatform initialPlatform = DynamicAppIconPlatform.instance;

  test('$MethodChannelDynamicAppIcon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDynamicAppIcon>());
  });

  test('getPlatformVersion', () async {
    DynamicAppIcon dynamicAppIconPlugin = DynamicAppIcon();
    MockDynamicAppIconPlatform fakePlatform = MockDynamicAppIconPlatform();
    DynamicAppIconPlatform.instance = fakePlatform;

    expect(await dynamicAppIconPlugin.getPlatformVersion(), '42');
  });
}
