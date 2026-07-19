package com.example.dynamic_app_icon.dynamic_app_icon

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DynamicAppIconPlugin */
class DynamicAppIconPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dynamic_app_icon")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isSupported" -> {
        // Stub implementation
        result.success(true)
      }
      "setIcon" -> {
        val iconName = call.argument<String>("iconName")
        if (iconName == null) {
          result.error("INVALID_ARGS", "Missing iconName", null)
          return
        }
        // Stub implementation - just return success
        result.success(null)
      }
      "getCurrentIcon" -> {
        // Stub implementation - return default
        result.success("default")
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
