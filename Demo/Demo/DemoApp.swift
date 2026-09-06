//
//  DemoApp.swift
//  Demo
//
//  Entry point: Configures the NavigationStack and injects the modifiers required by NavigationValues.
//
//  .navigationContext() — Attached to NavigationStack, initializes the navigation environment.
//  .screenContext()    — Attached to each Screen, creates an independent ScreenContext for that screen.
//

import SwiftUI
import NavigationValues

/// Manages the global navigation path (shared by all Screens).
@Observable
class NavigationPathManager {
    static let shared = NavigationPathManager()
    var path = NavigationPath()
}

@main
struct DemoApp: App {
    @State var manager = NavigationPathManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $manager.path) {
                Screen()
                    .screenContext(.navigationScreen)
                    .navigationDestination(for: String.self) { _ in
                        Screen()
                            .screenContext(.navigationScreen)
                    }
            }
            .screenContext(.navigationStack)
        }
    }
}
