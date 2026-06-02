//
//  ValueEntry.swift
//  NavigationValues
//
//  Created by TangTao on 2026/3/7.
//

import Foundation

public enum ValueEntryOption: Sendable {
    /// Indicates that the value should be ignored by the observation system.
    /// The updates of the value will not be propagated automatically to next screens, but more effective.
    case observationIgnored
}

/// Declares a value that can be set and get though a screen context.
/// - Parameters:
///   - options: The options for the value entry. See **ValueEntryOption**.
/// - Returns: A macro that declares a value entry for the screen context.
@attached(peer, names: prefixed(__Value_))
@attached(accessor)
public macro ValueEntry(_ options: ValueEntryOption...) = #externalMacro(module: "NavigationValuesMacros", type: "ValueEntryMacro")
