//
//  NavigationValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI
import Observation

public class NavigationStack: ScreenContext {
    public override var children: [ScreenContext] {
        get { super.children }
        set {
            if 1 < newValue.count {
                for (p, n) in zip(newValue, newValue.dropFirst(1)) {
                    p.next = n
                    n.previous = p
                }
            }
            super.children = newValue
        }
    }
    
    public override func handleNewChild(_ child: ScreenContext) {
        guard child.parent == nil else { return }
        
        super.handleNewChild(child)
        if child.previous == nil {
            child.previous = children.last
        }
    }
}

extension View {
    /// Declares a navigation stack.
    @ViewBuilder public func navigationContext() -> some View {
        screenContext(NavigationStack())
    }
}

struct ScreenContextViewModifier<T: ScreenContext>: ViewModifier {
    class OnRelease {
        var release: () -> Void = { }
        deinit { release() }
    }
    
    @Environment(\.screenContext) var parent
    
    @State var screenContext: T
    @State var onRelease: OnRelease = OnRelease()

    init(screenContext: T = T()) {
        self._screenContext = State(initialValue: screenContext)
    }
    
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.screenContext) { screenContext in
                onRelease.release = screenContext.cleanup
                parent.handleNewChild(screenContext)
            }
            .environment(\.screenContext, screenContext)
            .transformPreference(ScreenContext.Preference.self, { values in
                screenContext.children = values
                values = [screenContext]
            })
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}
