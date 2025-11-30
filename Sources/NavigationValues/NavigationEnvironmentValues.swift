//
//  NavigationEnvironmentValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/11/30.
//

import SwiftUI

struct NavigationEnvironmentValues {
    
    typealias KeyPathHash = Int
    
    var environmentValues: EnvironmentValues = EnvironmentValues()
    var keyPathes: Set<KeyPathHash> = []
    
    func contains<Member>(_ keyPath: WritableKeyPath<EnvironmentValues, Member>) -> Bool {
        keyPathes.contains(keyPath.hashValue)
    }
     
    subscript<Member>(env keyPath: WritableKeyPath<EnvironmentValues, Member>) -> Member {
        get {
            return environmentValues[keyPath: keyPath]
        }
        set {
            keyPathes.insert(keyPath.hashValue)
            environmentValues[keyPath: keyPath] = newValue
        }
    }
}
