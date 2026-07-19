import Flutter
import UIKit

public class DynamicAppIconPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dynamic_app_icon", binaryMessenger: registrar.messenger())
    let instance = DynamicAppIconPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      // Stub implementation
      result(true)
    case "setIcon":
      guard let args = call.arguments as? [String: Any],
            let iconName = args["iconName"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing iconName", details: nil))
        return
      }
      // Stub implementation - return success
      result(nil)
    case "getCurrentIcon":
      // Stub implementation - return default
      result("default")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
