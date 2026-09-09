# NavigationValues

**NavigationValues** is a lightweight SwiftUI library that solves one common pain point:

**SwiftUI's `NavigationStack` has no built-in, clean way to pass data forward and backward along the navigation stack.**

This library gives each screen a `ScreenContext` you can read and write, so values can travel to later screens and come back to earlier ones — without threading bindings through every destination.

## Features

- Pass values **forward** (previous → next) and **backward** (next → previous)
- Type-safe thanks to Swift generics and key paths
- Works naturally with `NavigationStack`
- Declarative API using a macro, environment, and view modifiers

## Core Concept

**In SwiftUI:**
Environment values flow down the view tree (parent → children).
Preference values flow up the view tree (children → parent).

**NavigationValues applies the same idea to the navigation stack:**

- **Forward values** behave like environment: a screen writes a value, and screens pushed after it can read it.
- **Backward values** behave like preferences: a later screen publishes a value, and earlier screens can observe it — and decide whether to keep passing it back.

## Requirements

- iOS 18+
- macOS 15+
- Swift 6

## Installation

Add NavigationValues as a Swift Package dependency in Xcode or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tstrawberry/NavigationValues.git", from: "1.1.0"),
]
```

Then add the `NavigationValues` library to your target.

## Quick Start

### 1. Attach a screen context

Put `.screenContext(.navigationStack)` on the `NavigationStack`, and `.screenContext(.navigationScreen)` on every destination (including the root).

```swift
NavigationStack(path: $path) {
    ContentView()
        .screenContext(.navigationScreen)
        .navigationDestination(for: Item.self) { item in
            DetailView(item: item)
                .screenContext(.navigationScreen)
        }
}
.screenContext(.navigationStack)
```

`.navigationStack` tells the stack to treat its destinations as a chain of screens. `.navigationScreen` registers each destination as one link in that chain. Without both, forward and backward values have nowhere to travel.

You can also pass a `configure` closure to set values as soon as the context is created:

```swift
DetailView(item: item)
    .screenContext(.navigationScreen) { context in
        context.title = item.name
    }
```

### 2. Declare forward-passing values

Add properties on `ScreenContext` with `@ValueEntry`. Any later screen can read (and override) them.

```swift
extension ScreenContext {
    @ValueEntry var title: String = ""
    @ValueEntry var counter: Int = 0
}
```

Use `@ValueEntry(.observationIgnored)` when a value should still be readable and writable, but changes should not trigger view updates.

### 3. Declare a backward-passing preference

Conform to `NavigationValues.PreferenceKey`. This is the type later screens publish and earlier screens listen for.

```swift
struct SelectedItem: NavigationValues.PreferenceKey {
    static let defaultValue: String = ""
}
```

### 4. Use values in a screen

Read the current screen's context from the environment. Bind forward values like any other `@Observable` model. Send a preference with `updatePreference`, and handle values from later screens with `onScreenPreferenceChange`.

```swift
struct DetailView: View {
    @Environment(\.screenContext) var screenContext
    @State private var selectedItem = ""

    var body: some View {
        @Bindable var screenContext = screenContext

        VStack {
            TextField("Title", text: $screenContext.title)

            Button("Send back") {
                screenContext.updatePreference(SelectedItem.self, value: "chosen")
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            screenContext.updatePreference(SelectedItem.self, value: newValue)
        }
        .onScreenPreferenceChange(SelectedItem.self) { value, passBack in
            selectedItem = value
            passBack(value) // omit this call to stop the value here
        }
    }
}
```

Calling `passBack` continues the value toward earlier screens. Not calling it stops propagation on this screen — useful when a screen should consume a result instead of forwarding it.

## Screen Context Behaviors

`.screenContext` takes a **behavior**. The behavior is how you say what this view is in the navigation structure:

| Behavior | Attach it to | What it is for |
| --- | --- | --- |
| `.navigationStack` | `NavigationStack` | Owns the stack and connects pushed screens so values can flow along it |
| `.navigationScreen` | Each destination (root included) | Registers this view as a screen in that stack |
| `.defaultBehavior` | Any view | Creates a local `ScreenContext` with no stack linking. This is the default of `.screenContext()` |

For `NavigationStack`, you want `.navigationStack` on the stack and `.navigationScreen` on every screen. Bare `.screenContext()` is enough only when you need a context that does **not** participate in stack-wide passing.

To support a different container (for example a custom pager), implement `ScreenContextBehavior` and pass your type to `.screenContext(_:)`. Built-in behaviors already cover the `NavigationStack` case.

## Accessing the current screen

```swift
@Environment(\.screenContext) var screenContext
```

`screenContext` is the context of **this** screen. With navigation behaviors attached, `previous` and `next` point at the adjacent screens on the stack, so a screen can look at its neighbors when needed.

See the **Demo** target in this repository for a complete example: forward `String` and `Int` values, a backward preference with optional blocking, and push/pop.

## License

NavigationValues is released under the [MIT License](LICENSE).
