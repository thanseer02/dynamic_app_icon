package com.example.dynamic_app_icon.dynamic_app_icon

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

internal class DynamicAppIconPluginTest {
  @Test
  fun onMethodCall_isSupported_returnsExpectedValue() {
    val plugin = DynamicAppIconPlugin()

    val call = MethodCall("isSupported", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).success(true)
  }
}
