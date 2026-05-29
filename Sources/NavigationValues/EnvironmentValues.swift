//
//  EnvironmentValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

@MainActor
public extension EnvironmentValues {
    class PlaceholderContext: ScreenContext {
        public required init() { }
    }
    
    private struct ScreenContextKey: @preconcurrency EnvironmentKey {
        @MainActor static let defaultValue: ScreenContext = PlaceholderContext()
    }
    
    var screenContext: ScreenContext {
        get {
            self[ScreenContextKey.self]
        }
        set {
            self[ScreenContextKey.self] = newValue
        }
    }
}
