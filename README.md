# NavigationValues

**NavigationValues** is a lightweight SwiftUI library that solves one common pain point:  

**SwiftUI's NavigationStack has no built-in, clean way to pass data forward and backward on navigation stack**.

This library provides a simple, type-safe, and idiomatic way to send values back up the navigation hierarchy.

## ✨ Features

- Send values **forward and back** on navigation stack
- Type-safe thanks to Swift generics & key paths
- Works naturally with `NavigationStack`
- Declarative API using property wrappers and view modifiers
- Zero external dependencies

## Core Conception

**In SwiftUI:**
Environment values flow downward along the view tree (from parent to children).
Preference values flow upward along the view tree (from children to parent).

**NavigationValues draws inspiration from this same abstraction model:**
Its "Environment-like" mechanism passes values forward along the navigation stack.
Its "Preference-like" mechanism passes values backward along the navigation stack.

In short:
NavigationValues reinterprets the classic Environment (down) + Preference (up) pattern, but applies it to the navigation hierarchy instead of the view tree.

## Requirements

- iOS 18+
- macOS 15+
- Swift 5

## Installation

Add NavigationValues as a Swift Package dependency in Xcode or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tstrawberry/NavigationValues.git", from: "1.0.2"),
]
```

Then add the `NavigationValues` library to your target.

## Quick Start

**1. Set up the navigation stack**

```swift
NavigationStack(path: $path) {
    ContentView()
        .screenContext()
        .navigationDestination(for: Item.self) { item in
            DetailView(item: item)
                .screenContext()
        }
}
.navigationContext()
```

**2. Define forward-passing values**

```swift
extension ScreenContext {
    @ValueEntry var title: String = ""
}
```

Use `@ValueEntry(.observationIgnored)` when a value should be readable and writable but should not trigger observation updates.


**3. Define a backward-passing preference**

```swift
struct SelectedItem: NavigationValues.PreferenceKey {
    static let defaultValue: String = ""
}
```

**4. Use values in a screen**

```swift
struct DetailView: View {
    @Environment(\.screenContext) var screenContext

    var body: some View {
        @Bindable var screenContext = screenContext

        TextField("Title", text: $screenContext.title)
            .onScreenPreferenceChange(SelectedItem.self) { value, backward in
                // Handle value from next screens
                backward(modifiedValue)
            }
    }
}
```

See the **Demo** target in this repository for a complete working example with forward values, backward preferences, and navigation.

## License

NavigationValues is released under the [MIT License](LICENSE).
