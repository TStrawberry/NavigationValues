//
//  NavigationEnvironmentValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/11/30.
//

import SwiftUI

struct NavigationEnvironmentValues<T> {
    
    typealias KeyPathHash = Int
    
    var dict: [KeyPathHash: Any] = [:]
    
    func contains<Member>(_ keyPath: KeyPath<T, Member>) -> Bool {
        dict[keyPath.hashValue] != nil
    }
     
    subscript<Member>(env keyPath: KeyPath<T, Member>) -> Member? {
        get {
            guard contains(keyPath) else { return nil }
            return dict[keyPath.hashValue] as? Member
        }
        set {
            dict[keyPath.hashValue] = newValue
        }
    }
}
