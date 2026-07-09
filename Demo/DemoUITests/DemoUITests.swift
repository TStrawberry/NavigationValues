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
    func testForwardValueIsInheritedByNextScreen() throws {
        app.forwardTextField.clearAndEnterText("shared-forward")
        
        app.pushScreen()
        XCTAssertEqual(app.forwardTextField.stringValue, "shared-forward")
    }
    
    @MainActor
    func testForwardValueSetOnLaterScreenDoesNotAffectEarlier() throws {
        app.forwardTextField.clearAndEnterText("earlier-forward")
        app.pushScreen()
        app.forwardTextField.clearAndEnterText("later-forward")
        app.popScreen()
        
        XCTAssertEqual(app.forwardTextField.stringValue, "earlier-forward")
    }
    
    @MainActor
    func testForwardValueUpdatesObservablyOnRootScreen() throws {
        app.startTimerButton.tap()
        
        let predicate = NSPredicate(format: "value != %@", "initial value")
        let expectation = expectation(for: predicate, evaluatedWith: app.forwardTextField)
        wait(for: [expectation], timeout: 3)
    }
    
    @MainActor
    func testMultiplePushLevelsPreserveForwardValue() throws {
        app.forwardTextField.clearAndEnterText("deep-forward")
        app.pushScreen()
        XCTAssertEqual(app.forwardTextField.stringValue, "deep-forward")
        
        app.pushScreen()
        XCTAssertEqual(app.forwardTextField.stringValue, "deep-forward")
    }
    
    // MARK: - Counter (Int @ValueEntry)
    
    @MainActor
    func testCounterDefaultOnRootScreen() throws {
        XCTAssertEqual(app.counterValueLabel.label, "0")
    }
    
    @MainActor
    func testCounterIncrement() throws {
        app.counterIncrementButton.tap()
        XCTAssertEqual(app.counterValueLabel.label, "1")
        
        app.counterIncrementButton.tap()
        XCTAssertEqual(app.counterValueLabel.label, "2")
    }
    
    @MainActor
    func testCounterDecrement() throws {
        app.counterIncrementButton.tap()
        app.counterIncrementButton.tap()
        app.counterDecrementButton.tap()
        XCTAssertEqual(app.counterValueLabel.label, "1")
    }
    
    @MainActor
    func testCounterReset() throws {
        app.counterIncrementButton.tap()
        app.counterIncrementButton.tap()
        app.counterIncrementButton.tap()
        app.counterResetButton.tap()
        XCTAssertEqual(app.counterValueLabel.label, "0")
    }
    
    @MainActor
    func testCounterIsInheritedByNextScreen() throws {
        app.counterIncrementButton.tap()
        app.counterIncrementButton.tap()
        app.pushScreen()
        
        XCTAssertEqual(app.counterValueLabel.label, "2")
    }
    
    @MainActor
    func testCounterSetOnLaterScreenDoesNotAffectEarlier() throws {
        app.counterIncrementButton.tap()
        app.pushScreen()
        app.counterIncrementButton.tap()
        app.counterIncrementButton.tap()
        app.popScreen()
        
        XCTAssertEqual(app.counterValueLabel.label, "1")
    }
    
    // MARK: - Backward preferences (PreferenceKey)
    
    @MainActor
    func testBackwardPreferencePropagatesToPreviousScreen() throws {
        app.pushScreen()
        app.backwardTextField.clearAndEnterText("from-later")
        app.popScreen()
        
        XCTAssertEqual(app.backwardTextField.stringValue, "from-later")
    }
    
    @MainActor
    func testBackwardPreferenceDoesNotPropagateWhenBlocked() throws {
        app.pushScreen()
        app.preventBackwardToggle.setSwitch(on: true)
        app.backwardTextField.clearAndEnterText("blocked")
        XCTAssertEqual(app.backwardTextField.stringValue, "blocked")
        app.popScreen()
        
        XCTAssertTrue(app.backwardTextField.isShowingBackwardPlaceholder)
    }
    
    @MainActor
    func testBackwardPreferencePropagatesWhenAllowed() throws {
        app.pushScreen()
        app.preventBackwardToggle.setSwitch(on: false)
        app.backwardTextField.clearAndEnterText("allowed")
        app.popScreen()
        
        XCTAssertEqual(app.backwardTextField.stringValue, "allowed")
    }
    
    // MARK: - Navigation stack integration
    
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
