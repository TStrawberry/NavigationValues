//
//  NavigationValues.swift
//  NavigationValues
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI
import Observation

struct ScreenContextViewModifier<Behavior: ScreenContextBehavior>: ViewModifier {
    class OnRelease {
        var release: @MainActor @Sendable () -> Void = { }
        deinit {
            Task { @MainActor [release]  in
                release()
            }
        }
    }
    
    @Environment(\.screenContext) var parent
    
    @State var screenContext: ScreenContext = ScreenContext()
    @State var onRelease: OnRelease = OnRelease()
    
    let behavior: Behavior
    let transformer: @MainActor (ScreenContext) -> Void
    
    init(behavior: Behavior, transformer: @MainActor @escaping (ScreenContext) -> Void = { _ in }) {
        self.behavior = behavior
        self.transformer = transformer
    }
    
    func body(content: Content) -> some View {
        content
            .transformPreference(ScreenContext.Preference.self) { values in
                screenContext.children = values
                behavior.context(screenContext, didUpdateChildren: values)
                
                values = [screenContext]
            }
            .transformEnvironment(\.screenContext) { _ in
                screenContext.flag = behavior.flag
                transformer(screenContext)
                
                onRelease.release = screenContext.cleanup
                screenContext.parent = parent

                behavior.context(screenContext, didAttachTo: parent)
            }
            .environment(\.screenContext, screenContext)
            .onPreferenceChange(ScreenContext.Preference.self) { values in }
    }
}
