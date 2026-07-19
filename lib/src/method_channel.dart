import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'interface.dart';

/// An implementation of [DynamicAppIconPlatform] that uses method channels.
class MethodChannelDynamicAppIcon extends DynamicAppIconPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dynamic_app_icon');

  @override
  Future<bool> isSupported() async {
    final support = await methodChannel.invokeMethod<bool>('isSupported');
    return support ?? false;
  }

  @override
  Future<void> setIcon({required String iconName}) async {
    await methodChannel.invokeMethod<void>('setIcon', {
      'iconName': iconName,
    });
  }

  @override
  Future<String?> getCurrentIcon() async {
    final name = await methodChannel.invokeMethod<String>('getCurrentIcon');
    return name;
  }
}
