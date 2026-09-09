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
///     .onScreenPreferenceChange(BackwardValue.self) { value, passBack in
///        backwardValue = value
///        if shouldPassBackward {
///            passBack(value)
///        }
///     }
///
/// - Note: The preference key is used to store and retrieve values from the screen context.
public protocol PreferenceKey {
    /// A closure that continues propagating a preference value toward earlier screens.
    typealias PassBack = (Value) -> Void
    
    associatedtype Value: Equatable
    
    static var defaultValue: Self.Value { get }
}

public extension View {
    /// Declares the screen context representing this view.
    /// - Parameters:
    ///   - behavior: A ``ScreenContextBehavior`` that extends the context
    ///     with custom capabilities through composition.
    ///   - configure: A closure that customizes the newly created ``ScreenContext``.
    /// - Returns: A view modified with a new ``ScreenContext`` using that behavior.
    func screenContext<Behavior: ScreenContextBehavior>(
        _ behavior: Behavior = .screen,
        configure: @MainActor @escaping (ScreenContext) -> Void = { _ in }
    ) -> some View {
        modifier(ScreenContext.ViewModifier(behavior: behavior, configure: configure))
    }
    
    /// Registers an action to perform when the value of a screen preference key changes.
    ///
    /// - Important: At the **same screen (page) level**, the registered callback is
    ///   invoked **only once**. Each ``ScreenContext`` stores a single action per
    ///   preference key; registering another `onScreenPreferenceChange` for the same
    ///   key on that screen **replaces** the previous callback. It does **not**
    ///   accumulate. Call `passBack` if the value should continue to earlier screens.
    ///
    /// - Parameters:
    ///   - key: The preference key type to observe for changes.
    ///   - action: A closure called with the new value and a ``PreferenceKey/PassBack``
    ///     handler when the preference changes.
    /// - Returns: A view that triggers the action when the specified preference changes.
    func onScreenPreferenceChange<K>(
        _ key: K.Type = K.self,
        perform action: @escaping (K.Value, K.PassBack) -> Void
    ) -> some View where K : NavigationValues.PreferenceKey, K.Value : Equatable {
        modifier(ScreenPreferenceViewModifier(key: key, action: action))
    }
}

struct ScreenPreferenceViewModifier<K>: ViewModifier where K : NavigationValues.PreferenceKey, K.Value : Equatable {
    @Environment(\.screenContext) var screenContext
    
    let key: K.Type
    let action: (K.Value, K.PassBack) -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: screenContext) {
                screenContext.updatePreferenceAction(key, action: action)
            }
    }
}
