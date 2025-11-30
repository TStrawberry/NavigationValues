// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "NavigationValuesMacros", type: "StringifyMacro")


@attached(accessor)
public macro ValueEntry<T>(_ keyPath: KeyPath<EnvironmentValues, T>) = #externalMacro(module: "NavigationValuesMacros", type: "ValueEntryMacro")
