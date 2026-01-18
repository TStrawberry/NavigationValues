//
//  NavigationPreferenceKey.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI

public protocol NavigationPreferenceKey {
    associatedtype Value: Equatable
    
    static var defaultValue: Self.Value { get }
}

public extension View {
    func navigationValues() -> some View {
        modifier(NavigationValuesViewModifier())
    }
    
    @ViewBuilder
    func onNavigationPreferenceChange<K>(_ key: K.Type = K.self, perform action: @escaping (inout K.Value) -> Void) -> some View where K : NavigationPreferenceKey, K.Value : Equatable {        
        modifier(NavigationPreferenceViewModifier(key: key, action: action))
    }
}

struct NavigationPreferenceViewModifier<K>: ViewModifier where K : NavigationPreferenceKey, K.Value : Equatable {
    @Environment(\.navigationValues) var navigationValues
    
    let key: K.Type
    let action: (inout K.Value) -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: navigationValues.address) {
                navigationValues.updatePreferenceAction(key, action: action)
            }
    }
}
