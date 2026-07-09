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
    @Environment(\.dismiss) var dismiss
    
    @State var backwardValue: String = ""
    @State var isPreventingPassingBack: Bool = false
    @State var timer: Timer?
    @State var depth: Int = 0
    
    /// Walk the ScreenContext linked list to count how deep we are
    func computeDepth() -> Int {
        var count = 0
        var current: ScreenContext? = screenContext
        while let prev = current?.previous {
            count += 1
            current = prev
        }
        return count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Level Indicator
                levelBadge
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                
                // MARK: - Forward Value Section
                sectionCard(
                    icon: "arrow.forward.circle.fill",
                    iconColor: .blue,
                    title: "Forward Value (Previous → Next)",
                    subtitle: "Declared with @ValueEntry, automatically propagates from the current screen to subsequently pushed screens",
                    detail: "When you modify a forward value on any screen, all screens pushed after it will inherit that value. However, changes made on a later screen are NOT propagated back — forward propagation is one-way."
                ) {
                    forwardValueContent
                }
                
                // MARK: - Counter (Int Forward Value)
                sectionCard(
                    icon: "number.circle.fill",
                    iconColor: .teal,
                    title: "Counter (Int-type Forward Value)",
                    subtitle: "Demonstrates that @ValueEntry supports Int, Bool, and other types as well",
                    detail: "Tap +/- to modify the counter. After pushing a new screen, it will inherit the current counter value. This is an independent forward value — it does not interfere with the String type above."
                ) {
                    counterContent
                }
                
                // MARK: - Backward Value Section
                sectionCard(
                    icon: "arrow.backward.circle.fill",
                    iconColor: .orange,
                    title: "Backward Value (Next → Previous)",
                    subtitle: "Declared via PreferenceKey, propagates from later screens back to earlier screens",
                    detail: "Values set on a screen are propagated back through the navigation stack via the Preference mechanism. Each screen layer can choose to: continue passing backward, or block the propagation (when the toggle is off)."
                ) {
                    backwardValueContent
                }
                
                // MARK: - Navigation Section
                sectionCard(
                    icon: "map.circle.fill",
                    iconColor: .green,
                    title: "Navigation",
                    subtitle: "Push new screen / Pop to previous screen",
                    detail: "Tapping Push creates a new Screen that automatically inherits the current forward values. After popping back, the backward value triggers back-propagation."
                ) {
                    navigationContent
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            depth = computeDepth()
        }
        // When backwardValue changes locally, update it into the ScreenContext Preference
        .onChange(of: backwardValue, initial: false) { _, newValue in
            screenContext.updatePreference(BackwardValue.self, value: newValue)
        }
        // Receive callbacks when a subsequent screen's backward preference changes
        .onScreenPreferenceChange(BackwardValue.self) { value, backward in
            backwardValue = value
            if isPreventingPassingBack == false {
                backward(value)
            }
        }
    }
    
    // MARK: - Level Badge
    
    var levelBadge: some View {
        HStack {
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: depth == 0 ? "house.fill" : "square.stack.3d.up.fill")
                    .font(.caption)
                Text(depth == 0 ? "Root Screen" : "Level \(depth + 1) Screen")
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(depth == 0 ? .blue : .purple)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill((depth == 0 ? Color.blue : Color.purple).opacity(0.12))
            )
            Spacer()
        }
    }
    
    // MARK: - Forward Value Content
    
    @ViewBuilder
    var forwardValueContent: some View {
        @Bindable var screenContext = screenContext
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "textformat")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("Type a value to pass forward...", text: $screenContext.fowardValue)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("forwardTextField")
            }
            
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Button {
                    var value = 0
                    screenContext.fowardValue = "0"
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        value += 1
                        screenContext.fowardValue = "\(value)"
                    }
                } label: {
                    Label("Start Timer Auto-Update", systemImage: "play.fill")
                }
                .accessibilityIdentifier("startTimerButton")
                .buttonStyle(.bordered)
                .tint(.blue)
                
                if timer != nil {
                    Button {
                        timer?.invalidate()
                        timer = nil
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            
            // Show inheritance info when not the root screen
            if screenContext.previous != nil {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Current forward value inherited from previous screen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Counter Content
    
    @ViewBuilder
    var counterContent: some View {
        @Bindable var screenContext = screenContext
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "number")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                HStack(spacing: 0) {
                    Button {
                        screenContext.counter -= 1
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(.teal)
                    .accessibilityIdentifier("counterDecrementButton")
                    
                    Text("\(screenContext.counter)")
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .frame(minWidth: 60)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .accessibilityIdentifier("counterValueLabel")
                    
                    Button {
                        screenContext.counter += 1
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .accessibilityIdentifier("counterIncrementButton")
                    
                    Spacer()
                    
                    Button {
                        screenContext.counter = 0
                    } label: {
                        Text("Reset")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .accessibilityIdentifier("counterResetButton")
                }
            }
            
            // Show inheritance info when not the root screen
            if screenContext.previous != nil {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.teal)
                    Text("Current counter inherited from previous screen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Backward Value Content
    
    var backwardValueContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "textformat")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("Type a value to pass backward...", text: $backwardValue)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("backwardTextField")
            }
            
            HStack(spacing: 10) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Toggle(isOn: $isPreventingPassingBack) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Allow passing backward to previous screens")
                            .font(.subheadline)
                        Text("When disabled, values from later screens are blocked and won't reach earlier screens")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .accessibilityIdentifier("preventBackwardToggle")
            }
            
            // Show current propagation status
            HStack(spacing: 4) {
                Image(systemName: isPreventingPassingBack ? "xmark.shield.fill" : "checkmark.shield.fill")
                    .font(.caption)
                    .foregroundColor(isPreventingPassingBack ? .red : .green)
                Text(isPreventingPassingBack
                     ? "Blocked — value will NOT reach earlier screens"
                     : "Allowed — value will propagate backward")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 2)
        }
    }
    
    // MARK: - Navigation Content
    
    var navigationContent: some View {
        HStack(spacing: 12) {
            Button {
                NavigationPathManager.shared.path.append("")
            } label: {
                Label("Push New Screen", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .accessibilityIdentifier("pushButton")
        }
    }
    
    // MARK: - Section Card Helper
    
    @ViewBuilder
    func sectionCard<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        detail: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.headline)
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
