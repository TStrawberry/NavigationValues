import Testing
@testable import NavigationValues

private struct TestStringPreference: PreferenceKey {
    static let defaultValue = ""
}

@Suite("ScreenContext")
@MainActor
struct ScreenContextTests {
    
    // MARK: - Environment values
    
    @Test func environmentReturnsLocalValueOnly() {
        let context = ScreenContext()
        let parent = ScreenContext()
        context.previous = parent
        parent.setEnvironment(\.previous, to: parent)
        
        #expect(context.environment(\.previous) == nil)
        #expect(parent.environment(\.previous) == .some(parent))
    }
    
    @Test func environmentValueInheritsFromPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.setEnvironment(\.next, to: child)
        
        #expect(child.environmentValue(\.next) == .some(child))
    }
    
    @Test func setEnvironmentStoresWithoutAffectingPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.setEnvironment(\.previous, to: parent)
        child.setEnvironment(\.previous, to: child)
        
        #expect(parent.environment(\.previous) == .some(parent))
        #expect(child.environment(\.previous) == .some(child))
    }
    
    @Test func envSubscriptInheritsFromPreviousWhenLocalUnset() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent[env: \.next] = child
        
        #expect(child[env: \.next] == .some(child))
    }
    
    @Test func envSubscriptSetStoresLocalOverlay() {
        let context = ScreenContext()
        let linked = ScreenContext()
        context[env: \.previous] = linked
        
        #expect(context[env: \.previous] == .some(linked))
        #expect(context.environment(\.previous) == .some(linked))
    }
    
    @Test func envSubscriptSkipsWriteWhenEquatableValueUnchanged() {
        let context = ScreenContext()
        let linked = ScreenContext()
        context[env: \.previous] = linked
        context[env: \.previous] = linked
        
        #expect(context[env: \.previous] == .some(linked))
    }
    
    // MARK: - Preferences
    
    @Test func updatePreferenceInvokesRegisteredAction() {
        let context = ScreenContext()
        var receivedValue: String?
        var backwardCalled = false
        
        context.updatePreferenceAction(TestStringPreference.self) { value, backward in
            receivedValue = value
            backward("upstream")
            backwardCalled = true
        }
        context.updatePreference(TestStringPreference.self, value: "hello")
        
        #expect(receivedValue == "hello")
        #expect(backwardCalled)
    }
    
    @Test func updatePreferencePropagatesToPreviousViaBackward() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentValue: String?
        
        parent.updatePreferenceAction(TestStringPreference.self) { value, _ in
            parentValue = value
        }
        child.updatePreferenceAction(TestStringPreference.self) { value, backward in
            backward(value)
        }
        child.updatePreference(TestStringPreference.self, value: "from-child")
        
        #expect(parentValue == "from-child")
    }
    
    @Test func updatePreferenceDelegatesToPreviousWhenLocalValueUnchanged() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentCallCount = 0
        
        parent.updatePreferenceAction(TestStringPreference.self) { _, _ in
            parentCallCount += 1
        }
        child.preferences[ObjectIdentifier(TestStringPreference.self)] = "same"
        child.updatePreference(TestStringPreference.self, value: "same")
        
        #expect(parentCallCount == 1)
    }
    
    @Test func updatePreferenceWithoutActionForwardsToPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentValue: String?
        
        parent.updatePreferenceAction(TestStringPreference.self) { value, _ in
            parentValue = value
        }
        child.updatePreference(TestStringPreference.self, value: "direct")
        
        #expect(parentValue == "direct")
    }
    
    // MARK: - Navigation chain
    
    @Test func headReturnsFirstContextInPreviousChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        second.previous = first
        third.previous = second
        
        #expect(third.head() === first)
        #expect(second.head() === first)
        #expect(first.head() === first)
    }
    
    @Test func tailReturnsLastContextInNextChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        first.next = second
        second.next = third
        
        #expect(first.tail() === third)
        #expect(second.tail() === third)
        #expect(third.tail() === third)
    }
    
    @Test func topReturnsDeepestChild() {
        let root = ScreenContext()
        let child = ScreenContext()
        let grandchild = ScreenContext()
        root.children = [child]
        child.children = [grandchild]
        
        #expect(root.top() === grandchild)
        #expect(child.top() === grandchild)
        #expect(grandchild.top() === grandchild)
    }
    
    @Test func isParentRecognizesDirectChild() {
        let parent = ScreenContext()
        let child = ScreenContext()
        let other = ScreenContext()
        parent.children = [child]
        
        #expect(parent.isParent(of: child))
        #expect(parent.isParent(of: other) == false)
    }
    
    // MARK: - Lifecycle
    
    @Test func cleanupClearsStoredState() {
        let context = ScreenContext()
        context.setEnvironment(\.previous, to: ScreenContext())
        context.updatePreference(TestStringPreference.self, value: "x")
        context.updatePreferenceAction(TestStringPreference.self) { _, _ in }
        
        context.cleanup()
        
        #expect(context.environment(\.previous) == nil)
    }
    
    @Test func equalityUsesObjectIdentity() {
        let a = ScreenContext()
        let b = ScreenContext()
        #expect(a == a)
        #expect(a != b)
    }
    
    @Test func preferenceReduceAccumulatesScreenContexts() {
        let first = ScreenContext()
        let second = ScreenContext()
        var value: [ScreenContext] = []
        ScreenContext.Preference.reduce(value: &value) {
            [first, second]
        }
        #expect(value.count == 2)
        #expect(value[0] === first)
        #expect(value[1] === second)
    }
}
