import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'interface.dart';

/// An implementation of [SwitchAppIconPlatform] that uses method channels.
class MethodChannelSwitchAppIcon extends SwitchAppIconPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('switch_app_icon');

  @override
  Future<bool> isSupported() async {
    final support = await methodChannel.invokeMethod<bool>('isSupported');
    return support ?? false;
  }

  @override
  Future<void> change({required String iconName}) async {
    await methodChannel.invokeMethod<void>('changeIcon', {
      'iconName': iconName,
    });
  }

  @override
  Future<void> reset() async {
    await methodChannel.invokeMethod<void>('resetIcon');
  }

  @override
  Future<String?> current() async {
    final active = await methodChannel.invokeMethod<String>('currentIcon');
    return active;
  }

  @override
  Future<List<String>> availableIcons() async {
    final icons = await methodChannel.invokeMethod<List<dynamic>>('availableIcons');
    if (icons == null) return const [];
    return icons.cast<String>();
  }
}
