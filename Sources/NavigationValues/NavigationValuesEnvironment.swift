//
//  NavigationValuesEnvironment.swift
//  NavigationEnvironment
//
//  Created by TangTao on 2025/9/9.
//

import SwiftUI
import Observation

@MainActor
@Observable
class NavigationValuesEnvironment {
    @ObservationIgnored var navigationValues: [NavigationValues] = []
    
    init() { }
}

struct NavigationValuesEnvironmentViewModifier: ViewModifier {
    @State var navigationValuesEnvironment = NavigationValuesEnvironment()
    
    func body(content: Content) -> some View {
        content
            .environment(navigationValuesEnvironment)
            .onPreferenceChange(NavigationValuesPreferenceKey.self) { values in
                navigationValuesEnvironment.navigationValues = values
            }
    }
}

public extension View {
    func navigationValuesEnvironment() -> some View {
        modifier(NavigationValuesEnvironmentViewModifier())
    }
}
