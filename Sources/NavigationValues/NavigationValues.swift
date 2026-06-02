//
//  NavigationValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI
import Observation

public struct LinkedScreenViewModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .transformPreference(ScreenContext.Preference.self) { values in
                for (prev, next) in zip(values, values.dropFirst()) {
                    prev.next = next
                    next.previous = prev
                }
            }
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}

class NavigationStack: ScreenContext { }

extension View {
    /// Links all of the child screen contexts.
    /// - Returns: A view modified with the linked screen context.
    @ViewBuilder public func linkScreens() -> some View {
        modifier(LinkedScreenViewModifier())
    }
    
    /// Declares a navigation stack.
    /// - Parameters:
    ///   - linkToPrevious: Indicates whether to link with the previous screen context. Used to correctly get the value when the view's body is computed for the first time. If there is a strict forward and backward relationship between screens, it is usually necessary to be **true**.
    /// - Returns: A view modified with the linked screen context.
    @ViewBuilder public func navigationContext(linkToPrevious: Bool = true) -> some View {
        linkScreens()
            .screenContext(NavigationStack(), linkToPrevious: linkToPrevious)
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
    let linkToPrevious: Bool
    
    init(screenContext: T = T(), linkToPrevious: Bool = false) {
        self._screenContext = State(initialValue: screenContext)
        self.linkToPrevious = linkToPrevious
    }
    
    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.screenContext) { screenContext in
                onRelease.release = screenContext.cleanup
                screenContext.parent = parent
                guard linkToPrevious, screenContext.previous == nil, !parent.isParent(of: screenContext) else { return }
                screenContext.previous = parent.children.last
            }
            .environment(\.screenContext, screenContext)
            .transformPreference(ScreenContext.Preference.self, { values in
                screenContext.children = values
                values = [screenContext]
            })
            .onPreferenceChange(ScreenContext.Preference.self) { _ in }
    }
}
