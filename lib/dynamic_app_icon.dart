import 'package:flutter/services.dart';
import 'src/interface.dart';
import 'src/types.dart';

export 'src/types.dart';

/// A Flutter plugin utility class to dynamically change the application launcher icon
/// at runtime using alternate icons pre-bundled and pre-configured.
class DynamicAppIcon {
  // Private constructor to prevent direct instantiation
  DynamicAppIcon._();

  static DynamicAppIconPlatform get _platform => DynamicAppIconPlatform.instance;

  /// Returns `true` if alternate dynamic icons are supported on the current platform/device context.
  ///
  /// Always returns `false` on unsupported platforms (like Web or Desktop).
  static Future<bool> isSupported() async {
    try {
      return await _platform.isSupported();
    } catch (_) {
      return false;
    }
  }

  /// Sets the application launcher icon to the specified [iconName].
  ///
  /// Pass `null` or `'default'` to revert to the primary app icon.
  ///
  /// Throws [DynamicAppIconException] if the action fails (e.g., if the platform is
  /// unsupported, the alias/icon name is not defined in configurations, or a native error occurs).
  static Future<void> setIcon(String? iconName) async {
    final hasSupport = await isSupported();
    if (!hasSupport) {
      throw const DynamicAppIconException(
        DynamicAppIconError.unsupportedPlatform,
        "Dynamic app icons are not supported on this platform or OS version.",
      );
    }

    final targetName = iconName ?? 'default';

    try {
      await _platform.setIcon(iconName: targetName);
    } on PlatformException catch (e) {
      if (e.code == "ICON_NOT_FOUND" || e.code == "INVALID_ARGS") {
        throw DynamicAppIconException(
          DynamicAppIconError.iconNotFound,
          "The icon name '$targetName' was not found in manifest or configuration files.",
        );
      }
      throw DynamicAppIconException(
        DynamicAppIconError.nativeImplementationError,
        e.message ?? "An error occurred during icon switch in the native platform layer.",
      );
    } catch (e) {
      throw DynamicAppIconException(
        DynamicAppIconError.unknown,
        e.toString(),
      );
    }
  }

  /// Retrieves the identifier name of the currently active alternate icon.
  ///
  /// Returns `null` if the default primary icon is active.
  static Future<String?> getCurrentIcon() async {
    try {
      final name = await _platform.getCurrentIcon();
      return (name == 'default' || name == null) ? null : name;
    } catch (_) {
      return null;
    }
  }
}
