//
//  Values.swift
//  Demo
//
//  Defines the custom NavigationValues types used in the Demo
//
//  Two core mechanisms:
//
//  1. @ValueEntry (Pass Forward / Previous → Next)
//     Declared in a ScreenContext extension using the @ValueEntry macro.
//     Values set on a screen are automatically inherited by all
//     subsequently pushed screens. Modifications on a later screen
//     do not affect earlier screens — one-way forward propagation.
//
//  2. PreferenceKey (Pass Backward / Next → Previous)
//     Conforms to the NavigationValues.PreferenceKey protocol.
//     Later screens modify values via screenContext.updatePreference(Key.self, value:).
//     Earlier screens receive callbacks via .onScreenPreferenceChange(Key.self).
//     Each screen layer can choose to continue passing backward or block it
//     (similar to SwiftUI's built-in Preference mechanism).
//

import NavigationValues
import SwiftUI

// MARK: - Backward Value (Next → Previous Example)

/// A PreferenceKey used to demonstrate passing a String value backward through the navigation stack.
///
/// Usage:
/// - Later screen: screenContext.updatePreference(BackwardValue.self, value: "hello")
/// - Earlier screen: .onScreenPreferenceChange(BackwardValue.self) { value, passBack in ... }
struct BackwardValue: NavigationValues.PreferenceKey {
    typealias Value = String
    static let defaultValue: String = ""
}

// MARK: - Forward Value (Previous → Next Examples)

extension ScreenContext {
    
    /// A String-type forward value with default "initial value".
    ///
    /// Characteristics:
    /// - Once set, all subsequently pushed screens automatically inherit the value.
    /// - Later screens can modify it, but changes only affect themselves and subsequent screens.
    /// - Supports @Observable tracking — the UI updates automatically when the value changes.
    @ValueEntry
    var fowardValue: String = "initial value"
    
    /// An Int-type forward value with default 0.
    ///
    /// Demonstrates that @ValueEntry also works with Int (and Bool, etc.).
    /// Can be updated dynamically via timers — later screens sync automatically.
    @ValueEntry
    var counter: Int = 0
}
