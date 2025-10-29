//
//  Values.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import NavigationValues
import SwiftUI

extension EnvironmentValues {
    @Entry var fullname: String = ""
}

extension EnvironmentValues {
    @Entry var firstName: String = ""
}

extension NavigationValues {
    var firstName: String {
        get {
            self[env: \.firstName] ?? "aaa"
        }
        set {
            self[env: \.firstName] = newValue
        }
    }
    
    var lastName: String {
        get {
            self[env: \.lastName] ?? ""
        }
        set {
            self[env: \.lastName] = newValue
        }
    }
    
    var names: [String] {
        get {
            self[env: \.names] ?? []
        }
        set {
            self[env: \.names] = newValue
        }
    }
}

struct MiddleName: NavigationPreferenceKey {
    typealias Value = String
    static let defaultValue: String = ""
}
