//
//  File.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

@MainActor
public extension EnvironmentValues {
    private struct NavigationValuesKey: @preconcurrency EnvironmentKey {
        @MainActor static let defaultValue = NavigationValues()
    }
    
    var navigationValues: NavigationValues {
        get {
            self[NavigationValuesKey.self] ?? NavigationValuesKey.defaultValue
        }
        set {
            self[NavigationValuesKey.self] = newValue
        }
    }
}
