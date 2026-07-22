import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel.dart';

/// The platform interface that all implementations of [SwitchAppIcon] must implement.
abstract class SwitchAppIconPlatform extends PlatformInterface {
  /// Constructs a SwitchAppIconPlatform.
  SwitchAppIconPlatform() : super(token: _token);

  static final Object _token = Object();

  static SwitchAppIconPlatform _instance = MethodChannelSwitchAppIcon();

  /// The default instance of [SwitchAppIconPlatform] to use.
  ///
  /// Defaults to [MethodChannelSwitchAppIcon].
  static SwitchAppIconPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SwitchAppIconPlatform] when
  /// they register themselves.
  static set instance(SwitchAppIconPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks if dynamic icons are supported on the current device.
  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  /// Changes the application app icon.
  Future<void> change({required String iconName}) {
    throw UnimplementedError('change() has not been implemented.');
  }

  /// Resets the application launcher icon back to its primary default icon.
  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }

  /// Gets the currently active alternate icon name.
  ///
  /// Returns `null` if the default primary icon is active.
  Future<String?> current() {
    throw UnimplementedError('current() has not been implemented.');
  }

  /// Retrieves a list of alternate icon names configured in the application.
  Future<List<String>> availableIcons() {
    throw UnimplementedError('availableIcons() has not been implemented.');
  }
}
