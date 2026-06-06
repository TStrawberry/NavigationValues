//
//  DemoUITestHelpers.swift
//  DemoUITests
//

import XCTest

extension XCUIApplication {
    var forwardTextField: XCUIElement {
        textFields["forwardTextField"]
    }
    
    var backwardTextField: XCUIElement {
        textFields["backwardTextField"]
    }
    
    var pushButton: XCUIElement {
        buttons["pushButton"]
    }
    
    var preventBackwardToggle: XCUIElement {
        if switches["preventBackwardToggle"].exists {
            return switches["preventBackwardToggle"]
        }
        if switches["Prevent Passing Backward"].exists {
            return switches["Prevent Passing Backward"]
        }
        return switches.firstMatch
    }
    
    var startTimerButton: XCUIElement {
        buttons["startTimerButton"]
    }
    
    func launchDemo() {
        launch()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
    
    func pushScreen() {
        pushButton.tap()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
    
    func popScreen() {
        forwardTextField.tap()
        XCTAssertTrue(navigationBars.buttons.firstMatch.waitForExistence(timeout: 5))
        navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(forwardTextField.waitForExistence(timeout: 5))
    }
}

extension XCUIElement {
    var stringValue: String {
        (value as? String) ?? ""
    }
    
    var isShowingBackwardPlaceholder: Bool {
        stringValue.isEmpty || stringValue == "Pass Backward"
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
