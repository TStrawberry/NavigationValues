//
//  DemoApp.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

enum Screen: Hashable {
    case firstnameInputScreen
    case lastnameInputScreen
    case fullNameScreen
}

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FirstNameInputScreen()
                    .navigationValues()
                    .navigationDestination(for: Screen.self) { screen in
                        destination(screen)
                            .navigationValues()
                    }
            }
            .navigationValuesEnvironment()
        }
    }
    
    @ViewBuilder
    func destination(_ screen: Screen) -> some View {
        switch screen {
        case .firstnameInputScreen:
            FirstNameInputScreen()
        case .lastnameInputScreen:
            LastNameInputScreen()
        case .fullNameScreen:
            FullNameScreen()
        }
    }
}

