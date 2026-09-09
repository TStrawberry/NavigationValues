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
    
    @Test func stackBehaviorLeavesChainEndsUnlinked() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        
        NavigationStackBehavior.navigationStack
            .context(ScreenContext(), didUpdateChildren: [first, second, third])
        
        #expect(first.previous == nil)
        #expect(third.next == nil)
    }
    
    @Test func stackBehaviorLinkingIsIdempotent() {
        let first = ScreenContext()
        let second = ScreenContext()
        let children = [first, second]
        let behavior = NavigationStackBehavior.navigationStack
        
        behavior.context(ScreenContext(), didUpdateChildren: children)
        behavior.context(ScreenContext(), didUpdateChildren: children)
        
        #expect(first.next === second)
        #expect(second.previous === first)
        #expect(first.previous == nil)
        #expect(second.next == nil)
    }
    
    @Test func stackBehaviorRoleIsNavigationStack() {
        #expect(NavigationStackBehavior.navigationStack.role == .navigationStack)
    }
    
    @Test func stackLinkedSiblingsExposeHeadAndTail() {
        let first = ScreenContext()
        let second = ScreenContext()
        let third = ScreenContext()
        
        NavigationStackBehavior.navigationStack
            .context(ScreenContext(), didUpdateChildren: [first, second, third])
        
        #expect(third.head() === first)
        #expect(first.tail() === third)
        #expect(second.head() === first)
        #expect(second.tail() === third)
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
        
        NavigationScreenBehavior.navigation
            .context(child, didAttachTo: parent)
        
        #expect(child.previous === first)
    }
    
    @Test func screenBehaviorAttachIsIdempotent() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        let behavior = NavigationScreenBehavior.navigation
        behavior.context(child, didAttachTo: parent)
        behavior.context(child, didAttachTo: parent)
        
        #expect(child.previous === first)
    }
    
    @Test func screenBehaviorDoesNotLinkChildToItself() {
        let parent = ScreenContext()
        let child = ScreenContext()
        parent.children = [child]
        
        NavigationScreenBehavior.navigation
            .context(child, didAttachTo: parent)
        
        #expect(child.previous == nil)
    }
    
    @Test func screenBehaviorDoesNotLinkSiblingsOnChildrenUpdate() {
        let first = ScreenContext()
        let second = ScreenContext()
        
        NavigationScreenBehavior.navigation
            .context(ScreenContext(), didUpdateChildren: [first, second])
        
        #expect(first.next == nil)
        #expect(second.previous == nil)
    }
    
    @Test func screenBehaviorLinksToLastChildWhenParentHasMany() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let last = ScreenContext()
        let child = ScreenContext()
        parent.children = [first, last]
        
        NavigationScreenBehavior.navigation
            .context(child, didAttachTo: parent)
        
        #expect(child.previous === last)
    }
    
    @Test func screenBehaviorLeavesPreviousNilWhenParentHasNoChildren() {
        let parent = ScreenContext()
        let child = ScreenContext()
        
        NavigationScreenBehavior.navigation
            .context(child, didAttachTo: parent)
        
        #expect(child.previous == nil)
    }
    
    @Test func screenBehaviorRoleIsScreen() {
        #expect(NavigationScreenBehavior.navigation.role == .screen)
    }
    
    // MARK: - DefaultScreenContextBehavior
    //
    // The default accessory is a no-op. ScreenContext itself never links
    // previous/next; that only happens when a linking behavior is invoked.
    
    @Test func defaultBehaviorDoesNotLinkSiblings() {
        let first = ScreenContext()
        let second = ScreenContext()
        
        DefaultScreenContextBehavior.screen
            .context(ScreenContext(), didUpdateChildren: [first, second])
        
        #expect(first.next == nil)
        #expect(second.previous == nil)
    }
    
    @Test func defaultBehaviorDoesNotLinkPreviousOnAttach() {
        let parent = ScreenContext()
        let first = ScreenContext()
        let child = ScreenContext()
        parent.children = [first]
        
        DefaultScreenContextBehavior.screen
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
    
    @Test func defaultBehaviorRoleIsScreen() {
        #expect(DefaultScreenContextBehavior.screen.role == .screen)
    }
}
