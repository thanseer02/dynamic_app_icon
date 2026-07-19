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
      result(true)
    case "changeIcon":
      guard let args = call.arguments as? [String: Any],
            let iconName = args["iconName"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing iconName", details: nil))
        return
      }
      result(nil)
    case "resetIcon":
      result(nil)
    case "currentIcon":
      result("default")
    case "availableIcons":
      result(["dark_icon", "festive_icon"])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
