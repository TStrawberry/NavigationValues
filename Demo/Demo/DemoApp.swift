//
//  DemoApp.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

@Observable
class NavigationPathManager {
    static let shared = NavigationPathManager()
    
    var path = NavigationPath()
}

struct PPP: SwiftUI.PreferenceKey {
    static var defaultValue: [Int] = []
    
    static func reduce(value: inout [Int], nextValue: () -> [Int]) {
        print("\(value)")
        print("\(nextValue())")
        value += nextValue()
    }
    
}


@main
struct DemoApp: App {
    @State var manager = NavigationPathManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $manager.path) {
                Screen()
                    .screenContext()
                    .navigationDestination(for: String.self) { screen in
                        Screen()
                            .screenContext()
                    }
            }
            .navigationManager()
        }
    }
}

