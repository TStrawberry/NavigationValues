import SwiftUI
import Testing
@testable import NavigationValues

@Suite("EnvironmentValues")
@MainActor
struct EnvironmentValuesTests {
    
    @Test func screenContextEnvironmentDefaultsToPlainContext() {
        let values = EnvironmentValues()
        #expect(type(of: values.screenContext) == ScreenContext.self)
    }
    
    @Test func screenContextEnvironmentCanBeReplaced() {
        var values = EnvironmentValues()
        let context = ScreenContext()
        values.screenContext = context
        #expect(values.screenContext === context)
    }
}
