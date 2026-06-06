//
//  DemoUITests.swift
//  DemoUITests
//
//  UI tests that exercise NavigationValues in the Demo app.
//

import XCTest

final class DemoUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchDemo()
    }
    
    // MARK: - Forward values (@ValueEntry)
    
    @MainActor
    func testForwardValueDefaultOnRootScreen() throws {
        XCTAssertEqual(app.forwardTextField.stringValue, "initial value")
    }
    
    @MainActor
    func testForwardValueIsInheritedByPushedScreen() throws {
        app.forwardTextField.clearAndEnterText("shared-forward")
        app.pushScreen()
        
        XCTAssertEqual(app.forwardTextField.stringValue, "shared-forward")
    }
    
    @MainActor
    func testForwardValueSetOnChildDoesNotOverwriteRoot() throws {
        app.forwardTextField.clearAndEnterText("root-forward")
        app.pushScreen()
        app.forwardTextField.clearAndEnterText("child-forward")
        app.popScreen()
        
        XCTAssertEqual(app.forwardTextField.stringValue, "root-forward")
    }
    
    @MainActor
    func testForwardValueUpdatesObservablyOnRootScreen() throws {
        app.startTimerButton.tap()
        
        let predicate = NSPredicate(format: "value != %@", "initial value")
        let expectation = expectation(for: predicate, evaluatedWith: app.forwardTextField)
        wait(for: [expectation], timeout: 3)
    }
    
    // MARK: - Backward preferences (PreferenceKey)
    
    @MainActor
    func testBackwardPreferencePropagatesToParentScreen() throws {
        app.pushScreen()
        app.backwardTextField.clearAndEnterText("from-child")
        app.popScreen()
        
        XCTAssertEqual(app.backwardTextField.stringValue, "from-child")
    }
    
    @MainActor
    func testBackwardPreferenceDoesNotPropagateWhenChildBlocksIt() throws {
        app.pushScreen()
        app.preventBackwardToggle.setSwitch(on: true)
        app.backwardTextField.clearAndEnterText("blocked")
        XCTAssertEqual(app.backwardTextField.stringValue, "blocked")
        app.popScreen()
        
        XCTAssertTrue(app.backwardTextField.isShowingBackwardPlaceholder)
    }
    
    @MainActor
    func testBackwardPreferenceStillPropagatesWhenChildAllowsIt() throws {
        app.pushScreen()
        app.preventBackwardToggle.setSwitch(on: false)
        app.backwardTextField.clearAndEnterText("allowed")
        app.popScreen()
        
        XCTAssertEqual(app.backwardTextField.stringValue, "allowed")
    }
    
    // MARK: - Navigation stack integration
    
    @MainActor
    func testMultiplePushLevelsPreserveForwardValue() throws {
        app.forwardTextField.clearAndEnterText("deep-forward")
        app.pushScreen()
        XCTAssertEqual(app.forwardTextField.stringValue, "deep-forward")
        
        app.pushScreen()
        XCTAssertEqual(app.forwardTextField.stringValue, "deep-forward")
    }
    
    @MainActor
    func testBackwardPreferenceFromDeepScreenReachesRoot() throws {
        app.pushScreen()
        app.pushScreen()
        app.backwardTextField.clearAndEnterText("from-deepest")
        app.popScreen()
        app.popScreen()
        
        XCTAssertEqual(app.backwardTextField.stringValue, "from-deepest")
    }
    
    @MainActor
    func testBackwardPreferenceBlockedByIntermediateScreen() throws {
        app.pushScreen()
        app.preventBackwardToggle.setSwitch(on: true)
        app.pushScreen()
        app.backwardTextField.clearAndEnterText("from-deepest")
        app.popScreen()
        XCTAssertEqual(app.backwardTextField.stringValue, "from-deepest")
        app.popScreen()
        
        XCTAssertTrue(app.backwardTextField.isShowingBackwardPlaceholder)
    }
}
