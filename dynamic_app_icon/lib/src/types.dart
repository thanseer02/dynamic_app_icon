/// Enum representing common error conditions when changing the app icon.
enum DynamicAppIconError {
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
class DynamicAppIconException implements Exception {
  /// The underlying error category.
  final DynamicAppIconError error;

  /// Human-readable explanation of why the dynamic icon switch failed.
  final String message;

  /// Create a new [DynamicAppIconException].
  const DynamicAppIconException(this.error, this.message);

  @override
  String toString() => "DynamicAppIconException ($error): $message";
}
