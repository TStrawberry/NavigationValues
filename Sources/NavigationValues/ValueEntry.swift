//
//  ValueEntry.swift
//  NavigationValues
//
//  Created by TangTao on 2026/3/7.
//

import Foundation

public enum ValueEntryOption: Sendable {
    case observationIgnored
}

@attached(peer, names: prefixed(__Value_))
@attached(accessor)
public macro ValueEntry(_ options: ValueEntryOption...) = #externalMacro(module: "NavigationValuesMacros", type: "ValueEntryMacro")
