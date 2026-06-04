import Testing
@testable import NavigationValues

@Suite("NavigationEnvironmentValues")
@MainActor
struct NavigationEnvironmentValuesTests {
    
    @Test func containsIsFalseWhenEmpty() {
        let values = NavigationEnvironmentValues<ScreenContext>()
        #expect(values.contains(\.parent) == false)
    }
    
    @Test func subscriptGetReturnsNilWhenUnset() {
        let values = NavigationEnvironmentValues<ScreenContext>()
        #expect(values[env: \.parent] == nil)
    }
    
    @Test func subscriptSetAndGetRoundTrip() {
        var values = NavigationEnvironmentValues<ScreenContext>()
        let parent = ScreenContext()
        values[env: \.parent] = parent
        #expect(values.contains(\.parent))
        #expect(values[env: \.parent] == .some(parent))
    }
    
    @Test func subscriptOverwriteReplacesValue() {
        var values = NavigationEnvironmentValues<ScreenContext>()
        let first = ScreenContext()
        let second = ScreenContext()
        values[env: \.previous] = first
        values[env: \.previous] = second
        #expect(values[env: \.previous] == .some(second))
    }
}
