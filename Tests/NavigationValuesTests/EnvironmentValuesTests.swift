import SwiftUI
import Testing
@testable import NavigationValues

@Suite("EnvironmentValues")
@MainActor
struct EnvironmentValuesTests {
    
    @Test func placeholderContextType() {
        let placeholder = EnvironmentValues.PlaceholderContext()
        #expect(type(of: placeholder) == EnvironmentValues.PlaceholderContext.self)
    }
    
    @Test func screenContextEnvironmentDefaultsToPlaceholder() {
        let values = EnvironmentValues()
        #expect(values.screenContext is EnvironmentValues.PlaceholderContext)
    }
    
    @Test func screenContextEnvironmentCanBeReplaced() {
        var values = EnvironmentValues()
        let context = ScreenContext()
        values.screenContext = context
        #expect(values.screenContext === context)
    }
}
