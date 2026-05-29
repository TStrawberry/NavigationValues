//
//  NavigationPreferenceKey.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

public protocol PreferenceKey {
    typealias Backward = (Value) -> Void
    
    associatedtype Value: Equatable
    
    static var defaultValue: Self.Value { get }
}

public extension View {
    func screenContext<T: ScreenContext>(_ type: T.Type = ScreenContext.self) -> some View {
        modifier(ScreenContextViewModifier<T>())
    }
    
    func screenContext<T: ScreenContext>(_ context: T) -> some View {
        modifier(ScreenContextViewModifier<T>(screenContext: context))
    }
    
    @ViewBuilder
    func onScreenPreferenceChange<K>(
        _ key: K.Type = K.self,
        perform action: @escaping (K.Value, K.Backward) -> Void
    ) -> some View where K : NavigationValues.PreferenceKey, K.Value : Equatable {
        modifier(ScreenPreferenceViewModifier(key: key, action: action))
    }
}

struct ScreenPreferenceViewModifier<K>: ViewModifier where K : NavigationValues.PreferenceKey, K.Value : Equatable {
    @Environment(\.screenContext) var screenContext
    
    let key: K.Type
    let action: (K.Value, K.Backward) -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: screenContext) {
                screenContext.updatePreferenceAction(key, action: action)
            }
    }
}
