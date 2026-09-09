//
//  ScreenContext+ViewModifier.swift
//  ScreenContextViewModifier
//
//  Created by TangTao on 2025/12/13.
//

import SwiftUI
import Observation


extension ScreenContext {
    struct ViewModifier<Behavior: ScreenContextBehavior>: SwiftUI.ViewModifier {
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
        let configure: @MainActor (ScreenContext) -> Void
        
        init(behavior: Behavior, configure: @MainActor @escaping (ScreenContext) -> Void = { _ in }) {
            self.behavior = behavior
            self.configure = configure
        }
        
        func body(content: Content) -> some View {
            content
                .transformPreference(ScreenContext.Preference.self) { values in
                    screenContext.children = values
                    behavior.context(screenContext, didUpdateChildren: values)
                    
                    values = [screenContext]
                }
                .transformEnvironment(\.screenContext) { _ in
                    guard screenContext.parent == nil else { return }
                    
                    screenContext.role = behavior.role
                    configure(screenContext)
                    
                    onRelease.release = screenContext.cleanup
                    screenContext.parent = parent

                    behavior.context(screenContext, didAttachTo: parent)
                }
                .environment(\.screenContext, screenContext)
                .onPreferenceChange(ScreenContext.Preference.self) { values in }
        }
    }
}
