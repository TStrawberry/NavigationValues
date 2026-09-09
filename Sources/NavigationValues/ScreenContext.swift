//
//  Node.swift
//  Node<T>
//
//  Created by TangTao on 2026/3/25.
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class ScreenContext {
    @ObservationIgnored public internal(set) weak var parent: ScreenContext?
    @ObservationIgnored public internal(set) var children: [ScreenContext] = []
    @ObservationIgnored public weak var previous: ScreenContext?
    @ObservationIgnored public weak var next: ScreenContext?
    
    @ObservationIgnored var environments = NavigationEnvironmentValues<ScreenContext>()
    @ObservationIgnored var preferences: [ObjectIdentifier: Any] = [:]
    @ObservationIgnored var preferenceActions: [ObjectIdentifier: (Any, (Any) -> Void) -> Void] = [:]
    
    /// Creates a screen context.
    /// - Parameter behavior: An optional ``ScreenContextBehavior`` that extends the
    ///   context with custom capabilities through composition. Defaults to `nil`.
    public init() {
        
    }
    
    public subscript<Member>(env keyPath: WritableKeyPath<ScreenContext, Member>) -> Member? {
        get {
            self.access(keyPath)
            return environments[env: keyPath] ?? previous?[env: keyPath]
        }
        set {
            guard shouldNotifyObservers(environments[env: keyPath], newValue) else {
                self.environments[env: keyPath] = newValue
                return
            }
            
            self.withMutation(keyPath: keyPath, mutation: {
                self.environments[env: keyPath] = newValue
            })
        }
    }
    
    public subscript<Member>(env keyPath: WritableKeyPath<ScreenContext, Member>) -> Member? where Member: Equatable {
        get {
            self.access(keyPath)
            return self.environmentValue(keyPath) ?? previous?[env: keyPath]
        }
        set {
            guard shouldNotifyObservers(environments[env: keyPath], newValue) else {
                self.environments[env: keyPath] = newValue
                return
            }
            
            self.withMutation(keyPath: keyPath, mutation: {
                self.environments[env: keyPath] = newValue
            })
        }
    }
    
    public subscript<Member>(env keyPath: WritableKeyPath<ScreenContext, Member>) -> Member? where Member: AnyObject {
        get {
            self.access(keyPath)
            return environments[env: keyPath] ?? previous?[env: keyPath]
        }
        set {
            guard shouldNotifyObservers(environments[env: keyPath], newValue) else {
                self.environments[env: keyPath] = newValue
                return
            }
            
            self.withMutation(keyPath: keyPath, mutation: {
                self.environments[env: keyPath] = newValue
            })
        }
    }
    
    public subscript<Member>(env keyPath: WritableKeyPath<ScreenContext, Member>) -> Member? where Member: Equatable & AnyObject {
        get {
            self.access(keyPath)
            return environments[env: keyPath] ?? previous?[env: keyPath]
        }
        set {
            guard shouldNotifyObservers(environments[env: keyPath], newValue) else {
                self.environments[env: keyPath] = newValue
                return
            }
            
            self.withMutation(keyPath: keyPath, mutation: {
                self.environments[env: keyPath] = newValue
            })
        }
    }
    
    public func updatePreference<K: PreferenceKey>( _ key: K.Type, value: K.Value) where K.Value : Equatable {
        let id = ObjectIdentifier(key)
        var shouldCallAction: Bool {
            if let existingValue = preferences[id] as? K.Value {
                return existingValue != value
            } else {
                return true
            }
        }
        
        if shouldCallAction {
            callPreferenceAction(key, value: value)
        } else {
            previous?.updatePreference(key, value: value)
        }
    }
    
    public func environment<Member>(_ keyPath: KeyPath<ScreenContext, Member>) -> Member? {
        self.environments[env: keyPath]
    }
    
    public func environmentValue<Member>(_ keyPath: KeyPath<ScreenContext, Member>) -> Member? {
        environments[env: keyPath] ?? previous?.environmentValue(keyPath)
    }
    
    public func setEnvironment<Member>(_ keyPath: WritableKeyPath<ScreenContext, Member>, to newValue: Member?) {
        environments[env: keyPath] = newValue
    }
    
    @discardableResult
    func withMutation<Value, Result>(keyPath: WritableKeyPath<ScreenContext, Value>, mutation: () throws -> Result) rethrows -> Result {
        self.willSet(keyPath)
        let result = try mutation()
        self.didSet(keyPath)
        return result
    }
    
    public func access<Member>(_ keyPath: KeyPath<ScreenContext, Member>) {
        self.access(keyPath: keyPath)
        self.previous?.access(keyPath)
    }
    
    public  func willSet<Member>(_ keyPath: WritableKeyPath<ScreenContext, Member>) {
        self._$observationRegistrar.willSet(self, keyPath: keyPath)
    }
    
    public func didSet<Member>(_ keyPath: WritableKeyPath<ScreenContext, Member>) {
        self._$observationRegistrar.didSet(self, keyPath: keyPath)
    }
    
    public func updatePreferenceAction<K: NavigationValues.PreferenceKey>(
        _ key: K.Type,
        action: @escaping (K.Value, K.PassBack) -> Void
    ) where K.Value : Equatable {
        preferenceActions[ObjectIdentifier(K.self)] = { anyValue, passBack in
            guard let value = anyValue as? K.Value else { return }
            action(value, { v in
                passBack(v as Any)
            })
        }
    }
    
    func callPreferenceAction<K: PreferenceKey>(_ key: K.Type, value: K.Value) {
        if let action = preferenceActions[ObjectIdentifier(key)] {
            action(value, { [previous] anyValue in
                guard let value = anyValue as? K.Value else { return }
                previous?.updatePreference(key, value: value)
            })
        } else {
            previous?.updatePreference(key, value: value)
        }
    }
    
    /// The first context in the `previous` chain, walking toward earlier screens.
    public func head() -> ScreenContext {
        guard let previous else { return self }
        return previous.head()
    }
    
    /// The last context in the `next` chain, walking toward later screens.
    public func tail() -> ScreenContext {
        guard let next else { return self }
        return next.tail()
    }
    
    public func top() -> ScreenContext {
        guard let lastChild = children.last else { return self }
        return lastChild.top()
    }
    
    public func isParent(of child: ScreenContext) -> Bool {
       return children.contains(where: { $0 === child })
    }
    
    /// Clears the context's stored state, then forwards to the behavior's cleanup hook.
    public func cleanup() {
        environments.dict.removeAll()
        preferences.removeAll()
        preferenceActions.removeAll()
    }
}

extension ScreenContext {
    /// The role a behavior stamps onto a ``ScreenContext``.
    ///
    /// Use ``screen`` for a regular screen and ``navigationStack`` for a stack
    /// that owns child screens.
    public struct Role: RawRepresentable, Hashable, Equatable, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let screen: Role = Role(rawValue: 0)
        public static let navigationStack: Role = Role(rawValue: 1)
    }
    
    @ValueEntry(.observationIgnored) public internal(set) var role: Role = .screen
}

extension ScreenContext {
    private func shouldNotifyObservers<Member>(_ lhs: Member?, _ rhs: Member?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?): return shouldNotifyObservers(l, r)
        case (nil, nil): return false
        default: return true
        }
    }
    
    private func shouldNotifyObservers<Member>(_ lhs: Member?, _ rhs: Member?) -> Bool where Member: Equatable {
        switch (lhs, rhs) {
        case let (l?, r?): return shouldNotifyObservers(l, r)
        case (nil, nil): return false
        default: return true
        }
    }
    
    private func shouldNotifyObservers<Member>(_ lhs: Member?, _ rhs: Member?) -> Bool where Member: AnyObject {
        switch (lhs, rhs) {
        case let (l?, r?): return shouldNotifyObservers(l, r)
        case (nil, nil): return false
        default: return true
        }
    }
    
    private func shouldNotifyObservers<Member>(_ lhs: Member?, _ rhs: Member?) -> Bool where Member: Equatable & AnyObject {
        switch (lhs, rhs) {
        case let (l?, r?): return shouldNotifyObservers(l, r)
        case (nil, nil): return false
        default: return true
        }
    }
}

extension ScreenContext: @preconcurrency Equatable {
    public static func == (lhs: ScreenContext, rhs: ScreenContext) -> Bool {
        return lhs === rhs
    }
}

extension ScreenContext {
    public struct Preference: SwiftUI.PreferenceKey {
        public static let defaultValue: [ScreenContext] = []
        
        public static func reduce(value: inout [ScreenContext], nextValue: () -> [ScreenContext]) {
            value += nextValue()
        }
    }
}
