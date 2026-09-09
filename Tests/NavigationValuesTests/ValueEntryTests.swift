import Testing
@testable import NavigationValues

extension ScreenContext {
    /// Observed forward value: later screens inherit it, and writes notify observers.
    @ValueEntry var testTitle: String = ""
    /// Same path as `testTitle`, but for an Equatable value type other than String.
    @ValueEntry var testCounter: Int = 0
    /// Readable and writable without observation; still inherits along `previous`.
    @ValueEntry(.observationIgnored) var testIgnoredNote: String = "default"
}

@Suite("ValueEntry")
@MainActor
struct ValueEntryTests {
    
    @Test func observedValueUsesDeclaredDefault() {
        #expect(ScreenContext().testTitle == "")
        #expect(ScreenContext().testCounter == 0)
    }
    
    @Test func observedValueCanBeAssigned() {
        let context = ScreenContext()
        context.testTitle = "Home"
        context.testCounter = 3
        
        #expect(context.testTitle == "Home")
        #expect(context.testCounter == 3)
    }
    
    @Test func observedValueInheritsFromPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.testTitle = "Shared"
        parent.testCounter = 7
        
        #expect(child.testTitle == "Shared")
        #expect(child.testCounter == 7)
    }
    
    @Test func observedValueLocalOverlayDoesNotChangePrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.testTitle = "Parent"
        child.testTitle = "Child"
        
        #expect(child.testTitle == "Child")
        #expect(parent.testTitle == "Parent")
    }
    
    @Test func observedValueWalksEntirePreviousChain() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        second.previous = first
        third.previous = second
        first.testTitle = "Root"
        
        #expect(third.testTitle == "Root")
        #expect(second.testTitle == "Root")
    }
    
    @Test func ignoredValueUsesDeclaredDefault() {
        #expect(ScreenContext().testIgnoredNote == "default")
    }
    
    @Test func ignoredValueCanBeAssigned() {
        let context = ScreenContext()
        context.testIgnoredNote = "note"
        
        #expect(context.testIgnoredNote == "note")
    }
    
    @Test func ignoredValueInheritsFromPrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.testIgnoredNote = "from-parent"
        
        #expect(child.testIgnoredNote == "from-parent")
    }
    
    @Test func ignoredValueLocalOverlayDoesNotChangePrevious() {
        let parent = ScreenContext()
        let child = ScreenContext()
        child.previous = parent
        parent.testIgnoredNote = "parent-note"
        child.testIgnoredNote = "child-note"
        
        #expect(child.testIgnoredNote == "child-note")
        #expect(parent.testIgnoredNote == "parent-note")
    }
    
    @Test func ignoredValueReturnsDefaultAfterCleanup() {
        let context = ScreenContext()
        context.testIgnoredNote = "temporary"
        
        context.cleanup()
        
        #expect(context.testIgnoredNote == "default")
        #expect(context.testTitle == "")
        #expect(context.testCounter == 0)
    }
}
