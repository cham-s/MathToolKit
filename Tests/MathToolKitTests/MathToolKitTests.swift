import XCTest
@testable import MathToolKit

final class MathToolKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MathToolKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
