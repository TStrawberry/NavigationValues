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
        XCTAssertEqual(app.screen(at: 0).forwardTextField.stringValue, "initial value")
    }
    
    @MainActor
    func testForwardValueIsInheritedByNextScreen() throws {
        app.screen(at: 0).forwardTextField.clearAndEnterText("shared-forward")
        
        app.pushScreen()
        XCTAssertEqual(app.screen(at: 1).forwardTextField.stringValue, "shared-forward")
    }
    
    @MainActor
    func testForwardValueSetOnLaterScreenDoesNotAffectEarlier() throws {
        app.screen(at: 0).forwardTextField.clearAndEnterText("earlier-forward")
        app.pushScreen()
        app.screen(at: 1).forwardTextField.clearAndEnterText("later-forward")
        app.popScreen()
        
        XCTAssertEqual(app.screen(at: 0).forwardTextField.stringValue, "earlier-forward")
    }
    
    @MainActor
    func testForwardValueUpdatesObservablyOnRootScreen() throws {
        app.screen(at: 0).startTimerButton.tap()
        
        let predicate = NSPredicate(format: "value != %@", "initial value")
        let expectation = expectation(for: predicate, evaluatedWith: app.screen(at: 0).forwardTextField)
        wait(for: [expectation], timeout: 3)
    }
    
    @MainActor
    func testMultiplePushLevelsPreserveForwardValue() throws {
        app.screen(at: 0).forwardTextField.clearAndEnterText("deep-forward")
        app.pushScreen()
        XCTAssertEqual(app.screen(at: 1).forwardTextField.stringValue, "deep-forward")
        
        app.pushScreen()
        XCTAssertEqual(app.screen(at: 2).forwardTextField.stringValue, "deep-forward")
    }
    
    // MARK: - Counter (Int @ValueEntry)
    
    @MainActor
    func testCounterDefaultOnRootScreen() throws {
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "0")
    }
    
    @MainActor
    func testCounterIncrement() throws {
        app.screen(at: 0).counterIncrementButton.tap()
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "1")
        
        app.screen(at: 0).counterIncrementButton.tap()
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "2")
    }
    
    @MainActor
    func testCounterDecrement() throws {
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterDecrementButton.tap()
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "1")
    }
    
    @MainActor
    func testCounterReset() throws {
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterResetButton.tap()
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "0")
    }
    
    @MainActor
    func testCounterIsInheritedByNextScreen() throws {
        app.screen(at: 0).counterIncrementButton.tap()
        app.screen(at: 0).counterIncrementButton.tap()
        app.pushScreen()
        
        XCTAssertEqual(app.screen(at: 1).counterValueLabel.label, "2")
    }
    
    @MainActor
    func testCounterSetOnLaterScreenDoesNotAffectEarlier() throws {
        app.screen(at: 0).counterIncrementButton.tap()
        app.pushScreen()
        app.screen(at: 1).counterIncrementButton.tap()
        app.screen(at: 1).counterIncrementButton.tap()
        app.popScreen()
        
        XCTAssertEqual(app.screen(at: 0).counterValueLabel.label, "1")
    }
    
    // MARK: - Backward preferences (PreferenceKey)
    
    @MainActor
    func testBackwardPreferencePropagatesToPreviousScreen() throws {
        app.pushScreen()
        app.screen(at: 1).backwardTextField.clearAndEnterText("from-later")
        app.popScreen()
        
        XCTAssertEqual(app.screen(at: 0).backwardTextField.stringValue, "from-later")
    }
    
    @MainActor
    func testBackwardPreferenceDoesNotPropagateWhenBlocked() throws {
        app.pushScreen()
        app.screen(at: 1).preventBackwardToggle.setSwitch(on: true)
        app.screen(at: 1).backwardTextField.clearAndEnterText("blocked")
        XCTAssertEqual(app.screen(at: 1).backwardTextField.stringValue, "blocked")
        app.popScreen()
        
        XCTAssertTrue(app.screen(at: 0).backwardTextField.isShowingBackwardPlaceholder)
    }
    
    @MainActor
    func testBackwardPreferencePropagatesWhenAllowed() throws {
        app.pushScreen()
        app.screen(at: 1).preventBackwardToggle.setSwitch(on: false)
        app.screen(at: 1).backwardTextField.clearAndEnterText("allowed")
        app.popScreen()
        
        XCTAssertEqual(app.screen(at: 0).backwardTextField.stringValue, "allowed")
    }
    
    // MARK: - Navigation stack integration
    
    @MainActor
    func testBackwardPreferenceFromDeepScreenReachesRoot() throws {
        app.pushScreen()
        app.pushScreen()
        app.screen(at: 2).backwardTextField.clearAndEnterText("from-deepest")
        app.popScreen()
        app.popScreen()
        
        XCTAssertEqual(app.screen(at: 0).backwardTextField.stringValue, "from-deepest")
    }
    
    @MainActor
    func testBackwardPreferenceBlockedByIntermediateScreen() throws {
        app.pushScreen()
        app.screen(at: 1).preventBackwardToggle.setSwitch(on: true)
        app.pushScreen()
        app.screen(at: 2).backwardTextField.clearAndEnterText("from-deepest")
        app.popScreen()
        XCTAssertEqual(app.screen(at: 1).backwardTextField.stringValue, "from-deepest")
        app.popScreen()
        
        XCTAssertTrue(app.screen(at: 0).backwardTextField.isShowingBackwardPlaceholder)
    }
}
