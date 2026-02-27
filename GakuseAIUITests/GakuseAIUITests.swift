import XCTest

final class GakuseAIUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test all tabs are accessible
        XCTAssertTrue(app.tabBars.buttons["学習ログ"].exists)
        XCTAssertTrue(app.tabBars.buttons["ポートフォリオ"].exists)
        XCTAssertTrue(app.tabBars.buttons["AI壁打ち"].exists)
        XCTAssertTrue(app.tabBars.buttons["プロフィール"].exists)
    }
}
