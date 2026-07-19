import Flutter
import UIKit
import XCTest

@testable import dynamic_app_icon

class RunnerTests: XCTestCase {

  func testIsSupported() {
    let plugin = DynamicAppIconPlugin()

    let call = FlutterMethodCall(methodName: "isSupported", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! Bool, true)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
