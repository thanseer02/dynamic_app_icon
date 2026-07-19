package com.example.dynamic_app_icon.dynamic_app_icon

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * DynamicAppIconPlugin
 *
 * Exposes alternate launcher icon manipulation methods over MethodChannel.
 */
class DynamicAppIconPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  internal var iconManager: IconManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    iconManager = IconManager(flutterPluginBinding.applicationContext)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dynamic_app_icon")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val manager = iconManager
    if (manager == null) {
      result.error("NATIVE_ERROR", "Plugin context not initialized.", null)
      return
    }

    try {
      when (call.method) {
        "isSupported" -> {
          result.success(manager.isSupported())
        }
        "changeIcon" -> {
          val iconName = call.argument<String>("iconName")
          if (iconName == null) {
            result.error("INVALID_ARGS", "Missing iconName argument", null)
            return
          }
          manager.changeIcon(iconName)
          result.success(null)
        }
        "resetIcon" -> {
          manager.resetToDefault()
          result.success(null)
        }
        "currentIcon" -> {
          result.success(manager.getCurrentIcon())
        }
        "availableIcons" -> {
          result.success(manager.getAvailableIcons())
        }
        else -> {
          result.notImplemented()
        }
      }
    } catch (e: IllegalArgumentException) {
      result.error("ICON_NOT_FOUND", e.message, null)
    } catch (e: Exception) {
      result.error("NATIVE_ERROR", e.message, e.stackTraceToString())
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
    iconManager = null
  }
}
