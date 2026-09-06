import Testing
@testable import NavigationValues

@Suite("ScreenContextBehavior")
@MainActor
struct ScreenContextBehaviorTests {
    
    // MARK: - NavigationStackBehavior
    //
    // The stack receives the full child list through preference, then links
    // adjacent siblings into a previous/next chain.
    
    @Test func stackBehaviorLinksAdjacentSiblings() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        let children = [first, second, third]
        
        NavigationStackBehavior.navigationStack
            .context(ScreenContext(), didUpdateChildren: children)
        
        #expect(first.next === second)
        #expect(second.previous === first)
        #expect(second.next === third)
        #expect(third.previous === second)
    }
    
    @Test func stackBehaviorWithSingleChildDoesNotLink() {
        let only = ScreenContext()
        
        NavigationStackBehavior.navigationStack
            .context(ScreenContext(), didUpdateChildren: [only])
        
        #expect(only.previous == nil)
        #expect(only.next == nil)
    }
    
    @Test func stackBehaviorDoesNotLinkPreviousOnAttach() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        NavigationStackBehavior.navigationStack
            .context(child, didAttachTo: parent)
        
        #expect(child.previous == nil)
    }
    
    // MARK: - NavigationScreenBehavior
    //
    // A screen, on attach, points previous at the parent's last child so values
    // can be read before preference has collected the new child into children.
    
    @Test func screenBehaviorLinksPreviousToParentsLastChild() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        NavigationScreenBehavior.navigationScreen
            .context(child, didAttachTo: parent)
        
        #expect(child.previous === first)
    }
    
    @Test func screenBehaviorAttachIsIdempotent() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        let behavior = NavigationScreenBehavior.navigationScreen
        behavior.context(child, didAttachTo: parent)
        behavior.context(child, didAttachTo: parent)
        
        #expect(child.previous === first)
    }
    
    @Test func screenBehaviorDoesNotLinkChildToItself() {
        let parent = ScreenContext()
        let child = ScreenContext()
        parent.children = [child]
        
        NavigationScreenBehavior.navigationScreen
            .context(child, didAttachTo: parent)
        
        #expect(child.previous == nil)
    }
    
    @Test func screenBehaviorDoesNotLinkSiblingsOnChildrenUpdate() {
        let first = ScreenContext()
        let second = ScreenContext()
        
        NavigationScreenBehavior.navigationScreen
            .context(ScreenContext(), didUpdateChildren: [first, second])
        
        #expect(first.next == nil)
        #expect(second.previous == nil)
    }
    
    // MARK: - DefaultScreenContextBehavior
    //
    // The default accessory is a no-op. ScreenContext itself never links
    // previous/next; that only happens when a linking behavior is invoked.
    
    @Test func defaultBehaviorDoesNotLinkSiblings() {
        let first = ScreenContext()
        let second = ScreenContext()
        
        DefaultScreenContextBehavior.defaultBehavior
            .context(ScreenContext(), didUpdateChildren: [first, second])
        
        #expect(first.next == nil)
        #expect(second.previous == nil)
    }
    
    @Test func defaultBehaviorDoesNotLinkPreviousOnAttach() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        DefaultScreenContextBehavior.defaultBehavior
            .context(child, didAttachTo: parent)
        
        #expect(child.previous == nil)
    }
    
    @Test func assigningChildrenWithoutInvokingBehaviorDoesNotLink() {
        let context = ScreenContext()
        let first = ScreenContext()
        let second = ScreenContext()
        
        context.children = [first, second]
        
        #expect(first.next == nil)
        #expect(second.previous == nil)
    }
}
