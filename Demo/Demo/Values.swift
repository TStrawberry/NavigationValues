//
//  Values.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import NavigationValues
import NavigationValuesMacro
import SwiftUI

extension EnvironmentValues {
    @Entry var fullname: String = ""
}

extension EnvironmentValues {
    @Entry var firstName: String = "initial first name"
    @Entry var lastName: String = "initial last name"
}

extension NavigationValues {
    @ValueEntry(\.firstName) var firstName: String
    @ValueEntry(\.lastName) var lastName: String
}

struct MiddleName: NavigationPreferenceKey {
    typealias Value = String
    static let defaultValue: String = ""
}
