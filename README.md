# NavigationValues

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0+-orange?style=flat-square&logo=swift" alt="Swift 6.0+"/>
  <img src="https://img.shields.io/badge/iOS-18.0+-007AFF?style=flat-square&logo=apple" alt="iOS 18.0+"/>
  <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey?style=flat-square" alt="Platforms"/>
  <img src="https://img.shields.io/github/license/yourusername/NavigationValues?style=flat-square" alt="MIT License"/>
</p>

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

## Usage

- Apply the navigationValues() on NavigationStack

```swift
NavigationStack {
    ...
}
.navigationValues()
```


- Apply the navigationValues() on the view which is supposed to receive any value sent from previous views on the NavigationStack 

```swift
NavigationStack {
    RootScreen()
        .navigationValues()
        .navigationDestination(for: ...) { screen in
            destination(screen)
                .navigationValues()
        }
}
.navigationValues()

```

- Define the fields that are passed

```
/// Pass forward
extension NavigationValues {
    @ValueEntry var firstName: String = "initial first name"
}

/// Pass backward
struct MiddleName: NavigationPreferenceKey {
    typealias Value = String
    static let defaultValue: String = ""
}

```

- Send values forward and receive values in next screen

```swift
struct FirstNameInputScreen: View {
    @Environment(\.navigationValues) var navigationValues
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        VStack {
            TextField("input first name", text: $navigationValues.firstName)
        }
    }
}

struct NextScreen: View {
    @Environment(\.navigationValues) var navigationValues
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        VStack {
            TextField("input first name", text: $navigationValues.firstName)
        }
    }
}

```

- Send values backward and receive values in previous screen

```swift

struct PreviousScreen: View {
    @State var middleName = ""
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        Text(middleName)        
            .onNavigationPreferenceChange(MiddleName.self, perform: { value, backward in
                backward(value)
            })
    }
}

struct MiddleNameInputScreen: View {
    @State var middleName = ""
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        TextField("Middle Name", text: $middleName)
            .onChange(of: middleName) { _, newValue in
                navigationValues.updatePreference(MiddleName.self, value: newValue)
            }
    }
}

```


## License
NavigationValues is under MIT license.
