import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel.dart';

/// The platform interface that all implementations of [DynamicAppIcon] must implement.
abstract class DynamicAppIconPlatform extends PlatformInterface {
  /// Constructs a DynamicAppIconPlatform.
  DynamicAppIconPlatform() : super(token: _token);

  static final Object _token = Object();

  static DynamicAppIconPlatform _instance = MethodChannelDynamicAppIcon();

  /// The default instance of [DynamicAppIconPlatform] to use.
  ///
  /// Defaults to [MethodChannelDynamicAppIcon].
  static DynamicAppIconPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DynamicAppIconPlatform] when
  /// they register themselves.
  static set instance(DynamicAppIconPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks if alternating app icons is supported on the current device.
  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  /// Sets the application app icon.
  ///
  /// Set [iconName] to `default` or `null` to revert to the primary app icon.
  Future<void> setIcon({required String iconName}) {
    throw UnimplementedError('setIcon() has not been implemented.');
  }

  /// Gets the current alternate app icon name.
  ///
  /// Returns `default` if the main/primary icon is used.
  Future<String?> getCurrentIcon() {
    throw UnimplementedError('getCurrentIcon() has not been implemented.');
  }
}
