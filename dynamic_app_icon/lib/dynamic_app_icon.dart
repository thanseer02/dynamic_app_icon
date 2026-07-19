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
  /// Throws [DynamicAppIconException] if the action fails (e.g., if the platform is
  /// unsupported, the alias/icon name is not defined in configurations, or a native error occurs).
  static Future<void> change(String iconName) async {
    final hasSupport = await isSupported();
    if (!hasSupport) {
      throw const DynamicAppIconException(
        DynamicAppIconError.unsupportedPlatform,
        "Dynamic app icons are not supported on this platform or OS version.",
      );
    }

    try {
      await _platform.change(iconName: iconName);
    } on PlatformException catch (e) {
      if (e.code == "ICON_NOT_FOUND" || e.code == "INVALID_ARGS") {
        throw DynamicAppIconException(
          DynamicAppIconError.iconNotFound,
          "The icon name '$iconName' was not found in manifest or configuration files.",
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

  /// Resets the application launcher icon back to its primary default icon.
  ///
  /// Throws [DynamicAppIconException] if the action fails.
  static Future<void> reset() async {
    final hasSupport = await isSupported();
    if (!hasSupport) {
      throw const DynamicAppIconException(
        DynamicAppIconError.unsupportedPlatform,
        "Dynamic app icons are not supported on this platform or OS version.",
      );
    }

    try {
      await _platform.reset();
    } on PlatformException catch (e) {
      throw DynamicAppIconException(
        DynamicAppIconError.nativeImplementationError,
        e.message ?? "An error occurred during icon reset in the native platform layer.",
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
  static Future<String?> current() async {
    try {
      final name = await _platform.current();
      return (name == 'default' || name == null) ? null : name;
    } catch (_) {
      return null;
    }
  }

  /// Returns a list of alternate icon names configured in the application.
  ///
  /// Returns an empty list if no alternate icons are set up or if the platform is not supported.
  static Future<List<String>> availableIcons() async {
    try {
      return await _platform.availableIcons();
    } catch (_) {
      return const [];
    }
  }
}
