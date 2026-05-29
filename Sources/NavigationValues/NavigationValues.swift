//
//  NavigationValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI
import Observation

extension EnvironmentValues {
    @Entry var shouldLinkScreens: Bool = false
}

public struct LinkedScreenViewModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .environment(\.shouldLinkScreens, true)
            .transformPreference(ScreenContext.Preference.self) { values in
                for (prev, next) in zip(values, values.dropFirst()) {
                    prev.next = next
                    next.previous = prev
                }
            }
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}

public struct NavigationManagerViewModifier: ViewModifier {
    class NavigationStack: ScreenContext { }
    
    @Environment(\.screenContext) var screenContext
    
    @State var navigationManager = NavigationStack()
    
    public func body(content: Content) -> some View {
        let _ = navigationManager.parent = screenContext
        
        content
            .screenContext(NavigationStack.self)
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}


extension View {
    @ViewBuilder public func linkingScreens() -> some View {
        modifier(LinkedScreenViewModifier())
    }
    
    @ViewBuilder public func navigationManager() -> some View {
        linkingScreens()
            .modifier(NavigationManagerViewModifier())
    }
}


struct ScreenContextViewModifier<T: ScreenContext>: ViewModifier {
    class OnRelease {
        var release: () -> Void = { }
        deinit { release() }
    }
    
    @Environment(\.screenContext) var parent
    @Environment(\.shouldLinkScreens) var shouldLinkScreens
    
    @State var screenContext: T
    @State var onRelease: OnRelease = OnRelease()
    
    init(screenContext: T = T()) {
        self._screenContext = State(initialValue: screenContext)
    }
    
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.screenContext) { screenContext in
                onRelease.release = screenContext.cleanup
                guard shouldLinkScreens, screenContext.previous == nil, !parent.isParent(of: screenContext) else { return }
                screenContext.previous = parent.children.last?.top()
            }
            .environment(\.screenContext, screenContext)
            .transformPreference(ScreenContext.Preference.self, { values in
                screenContext.children = values
                screenContext.parent = parent
                values = [screenContext]
            })
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}
