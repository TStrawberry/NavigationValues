//
//  Screen.swift
//  Demo
//
//  Created by TangTao on 2026/4/1.
//

import SwiftUI
import NavigationValues
import Observation

struct Screen: View {
    @Environment(\.screenContext) var screenContext
    @State var backwardValue: String = ""
    @State var isPreventingPassingBack: Bool = false
    @State var timer: Timer?
    
    var body: some View {
        @Bindable var screenContext = screenContext
        
        VStack {
            HStack {
                TextField("Pass Forward", text: $screenContext.fowardValue)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("forwardTextField")
                
                Button("Start Timer") {
                    var value = 0
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _  in
                        screenContext.fowardValue = "\(value)"
                        value += 1
                    })
                }
                .accessibilityIdentifier("startTimerButton")
            }
            
            TextField("Pass Backward", text: $backwardValue)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("backwardTextField")
            
            Toggle("Prevent Passing Backward", isOn: $isPreventingPassingBack)
                .toggleStyle(.switch)
                .accessibilityIdentifier("preventBackwardToggle")
            
            Button("Push") {
                NavigationPathManager.shared.path.append("")
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("pushButton")
        }
        .padding()
        .onChange(of: backwardValue, initial: false) { oldValue, newValue in
            screenContext.updatePreference(BackwardValue.self, value: newValue)
        }
        .onScreenPreferenceChange(BackwardValue.self) { value, backward in
            backwardValue = value
            if isPreventingPassingBack == false {
                backward(value)
            }
        }
    }
}
