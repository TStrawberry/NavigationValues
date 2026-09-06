//
//  NavigationPreferenceKey.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

/// A protocol that defines a preference that can be set backward.
///
///     struct BackwardValue: NavigationValues.PreferenceKey {
///         typealias Value = String
///         static let defaultValue: String = ""
///     }
///
///     .onScreenPreferenceChange(BackwardValue.self) { value, backward in
///        backwardValue = value
///        if shouldPassBackward {
///            backward(value)
///        }
///     }
///
/// - Note: The preference key is used to store and retrieve values from the screen context.
public protocol PreferenceKey {
    typealias Backward = (Value) -> Void
    
    associatedtype Value: Equatable
    
    static var defaultValue: Self.Value { get }
}

public extension View {
    /// Declares the screen context representing this view.
    /// - Parameter behavior: A ``ScreenContextBehavior`` that extends the context
    ///   with custom capabilities through composition.
    /// - Returns: A view modified with a new ``ScreenContext`` using that behavior.
    func screenContext<Behavior: ScreenContextBehavior>(
        _ behavior: Behavior = .defaultBehavior,
        transformer: @MainActor @escaping (ScreenContext) -> Void = { _ in }
    ) -> some View {
        modifier(ScreenContextViewModifier(behavior: behavior, transformer: transformer))
    }
    
    /// Registers an action to perform when the value of a screen preference key changes.
    /// - Parameters:
    ///   - key: The preference key type to observe for changes.
    ///   - action: A closure called with the new value sent back from screens and backward handler when the preference changes.
    /// - Returns: A view that triggers the action when the specified preference changes.
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
