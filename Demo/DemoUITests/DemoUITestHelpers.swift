//
//  DemoUITestHelpers.swift
//  DemoUITests
//
//

import XCTest

extension XCUIApplication {
    
    // MARK: - Forward Value
    
    var forwardTextField: XCUIElement {
        textFields["forwardTextField"]
    }
    
    var startTimerButton: XCUIElement {
        buttons["startTimerButton"]
    }
    
    // MARK: - Counter (Int Forward Value)
    
    var counterDecrementButton: XCUIElement {
        buttons["counterDecrementButton"]
    }
    
    var counterIncrementButton: XCUIElement {
        buttons["counterIncrementButton"]
    }
    
    var counterResetButton: XCUIElement {
        buttons["counterResetButton"]
    }
    
    var counterValueLabel: XCUIElement {
        staticTexts["counterValueLabel"]
    }
    
    // MARK: - Backward Value
    
    var backwardTextField: XCUIElement {
        textFields["backwardTextField"]
    }
    
    var preventBackwardToggle: XCUIElement {
        if switches["preventBackwardToggle"].exists {
            return switches["preventBackwardToggle"]
        }
        if switches["Allow passing backward to previous screens"].exists {
            return switches["Allow passing backward to previous screens"]
        }
        return switches.firstMatch
    }
    
    // MARK: - Navigation
    
    var pushButton: XCUIElement {
        buttons["pushButton"]
    }
    
    // MARK: - Launch & Navigation Helpers
    
    func launchDemo() {
        launch()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
    
    func pushScreen() {
        pushButton.tap()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
    
    /// Pops the current screen using the navigation bar back button.
    func popScreen() {
        let backButton = navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
}

extension XCUIElement {
    
    var stringValue: String {
        (value as? String) ?? ""
    }
    
    /// True if the backward text field shows its placeholder (empty or default text).
    var isShowingBackwardPlaceholder: Bool {
        let text = stringValue
        return text.isEmpty || text == "Type a value to pass backward..."
    }
    
    var isSwitchOn: Bool {
        if let stringValue = value as? String {
            return stringValue == "1"
        }
        if let intValue = value as? Int {
            return intValue == 1
        }
        return false
    }
    
    func setSwitch(on: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(waitForExistence(timeout: 5), file: file, line: line)
        guard isSwitchOn != on else { return }
        
        tap()
        if isSwitchOn == on { return }
        
        coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        
        let toggle = self
        let predicate = NSPredicate { _, _ in
            toggle.isSwitchOn == on
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, file: file, line: line)
    }
    
    func clearAndEnterText(_ text: String) {
        tap()
        if let current = value as? String, !current.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count)
            typeText(deleteString)
        }
        typeText(text)
    }
}
