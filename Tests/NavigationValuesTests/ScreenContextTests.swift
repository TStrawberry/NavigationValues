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
    
    @Test func environmentValueWalksEntirePreviousChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        second.previous = first
        third.previous = second
        first.setEnvironment(\.next, to: first)
        
        #expect(third.environmentValue(\.next) == .some(first))
        #expect(second.environmentValue(\.next) == .some(first))
    }
    
    @Test func environmentValuePrefersNearestLocalValue() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        second.previous = first
        third.previous = second
        first.setEnvironment(\.next, to: first)
        second.setEnvironment(\.next, to: second)
        
        #expect(third.environmentValue(\.next) == .some(second))
        #expect(first.environmentValue(\.next) == .some(first))
        #expect(first.environment(\.next) == .some(first))
        #expect(third.environment(\.next) == nil)
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
        var passBackCalled = false
        
        context.updatePreferenceAction(TestStringPreference.self) { value, passBack in
            receivedValue = value
            passBack("upstream")
            passBackCalled = true
        }
        context.updatePreference(TestStringPreference.self, value: "hello")
        
        #expect(receivedValue == "hello")
        #expect(passBackCalled)
    }
    
    @Test func updatePreferencePropagatesToPreviousViaBackward() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentValue: String?
        
        parent.updatePreferenceAction(TestStringPreference.self) { value, _ in
            parentValue = value
        }
        child.updatePreferenceAction(TestStringPreference.self) { value, passBack in
            passBack(value)
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
    
    @Test func updatePreferenceDoesNotPropagateWhenPassBackOmitted() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentValue: String?
        
        parent.updatePreferenceAction(TestStringPreference.self) { value, _ in
            parentValue = value
        }
        child.updatePreferenceAction(TestStringPreference.self) { _, _ in
            // Consume the value here instead of calling passBack.
        }
        child.updatePreference(TestStringPreference.self, value: "blocked")
        
        #expect(parentValue == nil)
    }
    
    @Test func updatePreferencePassBackCanRewriteValue() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        var parentValue: String?
        
        parent.updatePreferenceAction(TestStringPreference.self) { value, _ in
            parentValue = value
        }
        child.updatePreferenceAction(TestStringPreference.self) { _, passBack in
            passBack("rewritten")
        }
        child.updatePreference(TestStringPreference.self, value: "original")
        
        #expect(parentValue == "rewritten")
    }
    
    // MARK: - Role
    
    @Test func roleDefaultsToScreen() {
        #expect(ScreenContext().role == .screen)
    }
    
    @Test func roleCanBeAssigned() {
        let context = ScreenContext()
        context.role = .navigationStack
        
        #expect(context.role == .navigationStack)
    }
    
    @Test func roleInheritsFromPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.role = .navigationStack
        
        #expect(child.role == .navigationStack)
        #expect(parent.role == .navigationStack)
    }
    
    @Test func roleLocalValueOverridesPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.role = .navigationStack
        child.role = .screen
        
        #expect(child.role == .screen)
        #expect(parent.role == .navigationStack)
    }
    
    @Test func customRoleRoundTrips() {
        let custom = ScreenContext.Role(rawValue: 42)
        let context = ScreenContext()
        context.role = custom
        
        #expect(context.role == custom)
        #expect(context.role != .screen)
        #expect(context.role != .navigationStack)
    }
    
    @Test func rolesWithSameRawValueAreEqual() {
        #expect(ScreenContext.Role(rawValue: 0) == .screen)
        #expect(ScreenContext.Role(rawValue: 1) == .navigationStack)
        #expect(ScreenContext.Role.screen != .navigationStack)
    }
    
    // MARK: - Navigation chain
    
    @Test func headAndTailReturnSelfWhenUnlinked() {
        let context = ScreenContext()
        
        #expect(context.head() === context)
        #expect(context.tail() === context)
    }
    
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
    
    @Test func headAndTailWalkATwoScreenChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        first.next = second
        second.previous = first
        
        #expect(second.head() === first)
        #expect(first.tail() === second)
    }
    
    @Test func headAndTailWalkABidirectionalChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        first.next = second
        second.previous = first
        second.next = third
        third.previous = second
        
        #expect(first.head() === first)
        #expect(second.head() === first)
        #expect(third.head() === first)
        #expect(first.tail() === third)
        #expect(second.tail() === third)
        #expect(third.tail() === third)
    }
    
    @Test func headAndTailIgnoreParentAndChildren() {
        let context = ScreenContext()
        let parent = ScreenContext()
        let child = ScreenContext()
        context.parent = parent
        context.children = [child]
        
        #expect(context.head() === context)
        #expect(context.tail() === context)
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
    
    @Test func topFollowsLastChildAmongSiblings() {
        let root = ScreenContext()
        let older = ScreenContext()
        let newer = ScreenContext()
        let newerChild = ScreenContext()
        root.children = [older, newer]
        newer.children = [newerChild]
        
        #expect(root.top() === newerChild)
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
        var actionCalled = false
        context.setEnvironment(\.previous, to: ScreenContext())
        context.role = .navigationStack
        context.updatePreference(TestStringPreference.self, value: "x")
        context.updatePreferenceAction(TestStringPreference.self) { _, _ in
            actionCalled = true
        }
        
        context.cleanup()
        context.updatePreference(TestStringPreference.self, value: "after-cleanup")
        
        #expect(context.environment(\.previous) == nil)
        #expect(context.role == .screen)
        #expect(actionCalled == false)
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
    
    @Test func preferenceDefaultValueIsEmpty() {
        #expect(ScreenContext.Preference.defaultValue.isEmpty)
    }
}
