//
//  DemoUITestHelpers.swift
//  DemoUITests
//
//

import XCTest

/// One pushed `Screen` in the navigation stack.
///
/// Every screen reuses the same control identifiers (`forwardTextField`, etc.).
/// Query through this container (`screen-0`, `screen-1`, ...) so tests talk to
/// the intended layer instead of the first match in the whole app.
struct DemoScreen {
    let element: XCUIElement
    
    // MARK: - Forward Value
    
    var forwardTextField: XCUIElement {
        element.textFields["forwardTextField"]
    }
    
    var startTimerButton: XCUIElement {
        element.buttons["startTimerButton"]
    }
    
    // MARK: - Counter (Int Forward Value)
    
    var counterDecrementButton: XCUIElement {
        element.buttons["counterDecrementButton"]
    }
    
    var counterIncrementButton: XCUIElement {
        element.buttons["counterIncrementButton"]
    }
    
    var counterResetButton: XCUIElement {
        element.buttons["counterResetButton"]
    }
    
    var counterValueLabel: XCUIElement {
        element.staticTexts["counterValueLabel"]
    }
    
    // MARK: - Backward Value
    
    var backwardTextField: XCUIElement {
        element.textFields["backwardTextField"]
    }
    
    var preventBackwardToggle: XCUIElement {
        let byIdentifier = element.switches["preventBackwardToggle"]
        if byIdentifier.exists {
            return byIdentifier
        }
        let byLabel = element.switches["Allow passing backward to previous screens"]
        if byLabel.exists {
            return byLabel
        }
        return element.switches.firstMatch
    }
    
    // MARK: - Navigation
    
    var pushButton: XCUIElement {
        element.buttons["pushButton"]
    }
    
    func waitForExistence(timeout: TimeInterval) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}

extension XCUIApplication {
    
    private static let screenIdentifierPrefix = "screen-"
    
    /// Depth of the visible screen (`0` = root).
    ///
    /// After a push, only the top `screen-N` is typically in the tree
    /// (for example `screen-2` with no `screen-0` / `screen-1`). Scan from
    /// the highest plausible depth so missing intermediate IDs are fine.
    var currentDepth: Int {
        for depth in stride(from: 8, through: 0, by: -1) {
            if screen(at: depth).element.exists {
                return depth
            }
        }
        return 0
    }
    
    func screen(at depth: Int) -> DemoScreen {
        DemoScreen(element: descendants(matching: .any)["\(Self.screenIdentifierPrefix)\(depth)"])
    }
    
    var currentScreen: DemoScreen {
        screen(at: currentDepth)
    }
    
    // MARK: - Launch & Navigation Helpers
    
    func launchDemo() {
        launch()
        XCTAssertTrue(screen(at: 0).waitForExistence(timeout: 5))
    }
    
    func pushScreen() {
        let nextDepth = currentDepth + 1
        currentScreen.pushButton.tap()
        XCTAssertTrue(screen(at: nextDepth).waitForExistence(timeout: 5))
        XCTAssertTrue(screen(at: nextDepth).forwardTextField.waitForExistence(timeout: 5))
    }
    
    /// Pops the current screen using the navigation bar back button.
    func popScreen() {
        let depthToPop = currentDepth
        XCTAssertGreaterThan(depthToPop, 0, "Cannot pop the root screen")
        
        let backButton = buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        
        // The previous screen typically leaves the tree while covered, then
        // comes back after pop — wait for that identifier to reappear.
        XCTAssertTrue(screen(at: depthToPop - 1).waitForExistence(timeout: 5))
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
