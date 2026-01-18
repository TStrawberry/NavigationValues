


import SwiftUI
import Observation

@MainActor
@Observable
public class NavigationValues {
    static let defaultEnvironmentValues = EnvironmentValues()
    
    var address: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }
    
    @ObservationIgnored weak var previous: NavigationValues?
    @ObservationIgnored weak var next: NavigationValues?
    
    @ObservationIgnored var environments = NavigationEnvironmentValues()
    @ObservationIgnored var preferences: [ObjectIdentifier: Any] = [:]
    @ObservationIgnored var preferenceActions: [ObjectIdentifier: (inout Any) -> Void] = [:]

    public subscript<Member>(env keyPath: WritableKeyPath<EnvironmentValues, Member>) -> Member {
        get {
            let transformedKeyPath = transformKeyPath(keyPath)
            
            self.access(keyPath: transformedKeyPath)
            return environments.contains(keyPath) ? environments[env: keyPath] : (previous?[env: keyPath] ?? Self.defaultEnvironmentValues[keyPath: keyPath])
        }
        set {
            let transformedKeyPath = transformKeyPath(keyPath)
            
            self.willSet(keyPath: transformedKeyPath)
            self.environments[env: keyPath] = newValue
            self.didSet(keyPath: transformedKeyPath)
        }
    }
    
    public func updatePreference<K: NavigationPreferenceKey>( _ key: K.Type, value: K.Value) where K.Value : Equatable {
        previous?.updatePreferenceValue(key, value: value)
    }
    
    func willSet<Member>(keyPath: WritableKeyPath<NavigationValues, Member>) {
        var values: NavigationValues? = self
        
        while let vls = values {
            self._$observationRegistrar.willSet(vls, keyPath: keyPath)
            values = vls.next
        }
    }
    
    func didSet<Member>(keyPath: WritableKeyPath<NavigationValues, Member>) {
        var values: NavigationValues? = self
        
        while let vls = values {
            self._$observationRegistrar.didSet(vls, keyPath: keyPath)
            values = vls.next
        }
    }
    
    func access<Member>(keyPath: KeyPath<NavigationValues, Member>) {
        var values: NavigationValues? = self
        while let vls = values {
            self._$observationRegistrar.access(vls, keyPath: keyPath)
            values = vls.previous
        }
    }
    
    func updatePreferenceAction<K: NavigationPreferenceKey>(
        _ key: K.Type,
        action: @escaping (inout K.Value) -> Void
    ) where K.Value : Equatable {
        preferenceActions[ObjectIdentifier(K.self)] = { anyValue in
            guard var value = anyValue as? K.Value else { return }
            action(&value)
        }
    }
    
    func transformKeyPath<Member>(_ keyPath: WritableKeyPath<EnvironmentValues, Member>) -> WritableKeyPath<NavigationValues, Member> {
        let environmentValues: WritableKeyPath<NavigationValues, EnvironmentValues> = \.environments.environmentValues
        return environmentValues.appending(path: keyPath)
    }
    
    func updatePreferenceValue<K: NavigationPreferenceKey>( _ key: K.Type, value: K.Value) where K.Value : Equatable {
        let id = ObjectIdentifier(key)
        var shouldCallAction: Bool {
            if let existingValue = preferences[id] as? K.Value {
                return existingValue != value
            } else {
                return true
            }
        }
        
        var mutipleValue = value as Any
        if shouldCallAction {
            preferenceActions[id]?(&mutipleValue)
        }
        previous?.updatePreferenceValue(key, value: mutipleValue as! K.Value)
    }
}

extension NavigationValues: @preconcurrency Equatable {
    public static func == (lhs: NavigationValues, rhs: NavigationValues) -> Bool {
        return lhs.address == rhs.address
    }
}

struct NavigationValuesPreferenceKey: PreferenceKey {
    static let defaultValue: [NavigationValues] = []
    
    static func reduce(value: inout [NavigationValues], nextValue: () -> [NavigationValues]) {
        let values = nextValue()
        if let last = value.last {
            link(values, to: last)
        }
        value += nextValue()
    }
    
    static func link(_ navigationValues: [NavigationValues], to previous: NavigationValues) {
        for (pre, next) in zip([previous] + navigationValues, navigationValues) {
            MainActor.assumeIsolated {
                (pre.next, next.previous) = (next, pre)
            }
        }
    }
}

struct NavigationValuesViewModifier: ViewModifier {
    @Environment(NavigationValuesEnvironment.self) var navigationValuesEnvironment
    @State var navigationValues = NavigationValues()
    
    func body(content: Content) -> some View {
        let _ = {
            if let last = navigationValuesEnvironment.navigationValues.last, last != navigationValues {
                navigationValues.previous = navigationValuesEnvironment.navigationValues.last
            }
        }()
        
        content
            .environment(\.navigationValues, navigationValues)
            .preference(key: NavigationValuesPreferenceKey.self, value: [navigationValues])
    }
}

