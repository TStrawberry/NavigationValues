//
//  Values.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import NavigationValues
import SwiftUI

struct BackwardValue: NavigationValues.PreferenceKey {
    typealias Value = String
    static let defaultValue: String = ""
}

extension ScreenContext {
    @ValueEntry 
    var fowardValue: String = "initial value"
}
