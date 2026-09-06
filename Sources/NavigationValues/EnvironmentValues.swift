//
//  EnvironmentValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

@MainActor
public extension EnvironmentValues {
    private struct ScreenContextKey: @preconcurrency EnvironmentKey {
        @MainActor static let defaultValue: ScreenContext = ScreenContext()
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
