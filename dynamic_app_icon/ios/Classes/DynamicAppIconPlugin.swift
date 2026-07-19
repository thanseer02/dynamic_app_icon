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
      result(UIApplication.shared.supportsAlternateIcons)
    case "changeIcon":
      guard let args = call.arguments as? [String: Any],
            let iconName = args["iconName"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing iconName argument", details: nil))
        return
      }
      changeIcon(iconName, result: result)
    case "resetIcon":
      changeIcon("default", result: result)
    case "currentIcon":
      result(UIApplication.shared.alternateIconName ?? "default")
    case "availableIcons":
      result(getAvailableIcons())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func changeIcon(_ iconName: String, result: @escaping FlutterResult) {
    let finalIconName = (iconName == "default") ? nil : iconName

    // If changing to an alternate icon (non-default), validate that it's configured in Info.plist first
    if let alternateName = finalIconName {
      let available = getAvailableIcons()
      if !available.contains(alternateName) {
        result(FlutterError(
          code: "ICON_NOT_FOUND",
          message: "The alternate icon '\(alternateName)' was not found in Info.plist configuration.",
          details: nil
        ))
        return
      }
    }

    // setAlternateIconName must be called on the main thread
    DispatchQueue.main.async {
      UIApplication.shared.setAlternateIconName(finalIconName) { error in
        if let error = error {
          result(FlutterError(
            code: "NATIVE_ERROR",
            message: error.localizedDescription,
            details: error.localizedFailureReason
          ))
        } else {
          result(nil)
        }
      }
    }
  }

  private func getAvailableIcons() -> [String] {
    var iconNames = Set<String>()

    // Check primary Bundle.main.infoDictionary under CFBundleIcons
    if let bundleIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
       let alternateIcons = bundleIcons["CFBundleAlternateIcons"] as? [String: Any] {
      iconNames.formUnion(alternateIcons.keys)
    }

    // Check iPad equivalents under CFBundleIcons~ipad
    if let bundleIconsIpad = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons~ipad") as? [String: Any],
       let alternateIconsIpad = bundleIconsIpad["CFBundleAlternateIcons"] as? [String: Any] {
      iconNames.formUnion(alternateIconsIpad.keys)
    }

    return Array(iconNames).sorted()
  }
}
