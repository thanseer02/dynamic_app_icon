/// Enum representing common error conditions when changing the app icon.
enum SwitchAppIconError {
  /// The platform or operating system version is not supported.
  unsupportedPlatform,

  /// The requested alternate icon name was not found in the configuration/manifest.
  iconNotFound,

  /// An error occurred in the native implementation platform wrapper.
  nativeImplementationError,

  /// Unknown or unclassified error.
  unknown;
}

/// Custom Exception thrown when dynamic app icon operations fail.
class SwitchAppIconException implements Exception {
  /// The underlying error category.
  final SwitchAppIconError error;

  /// Human-readable explanation of why the dynamic icon switch failed.
  final String message;

  /// Create a new [SwitchAppIconException].
  const SwitchAppIconException(this.error, this.message);

  @override
  String toString() => "SwitchAppIconException ($error): $message";
}
