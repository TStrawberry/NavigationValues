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
open class ScreenContext {
    @ObservationIgnored public internal(set) weak var parent: ScreenContext?
    @ObservationIgnored public internal(set) var children: [ScreenContext] = []
    @ObservationIgnored public weak var previous: ScreenContext?
    @ObservationIgnored public weak var next: ScreenContext?
    
    @ObservationIgnored var environments = NavigationEnvironmentValues<ScreenContext>()
    @ObservationIgnored var preferences: [ObjectIdentifier: Any] = [:]
    @ObservationIgnored var preferenceActions: [ObjectIdentifier: (Any, (Any) -> Void) -> Void] = [:]
    
    public required init() {
        
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
    
    func transformKeyPath<Node, Member>(_ keyPath: KeyPath<Node, Member>) -> KeyPath<Node, Member> {
        return keyPath
    }
    
    public func access<Member>(_ keyPath: KeyPath<ScreenContext, Member>) {
        self.access(keyPath: transformKeyPath(keyPath))
        self.previous?.access(keyPath)
    }
    
    public  func willSet<Member>(_ keyPath: WritableKeyPath<ScreenContext, Member>) {
        self._$observationRegistrar.willSet(self, keyPath: transformKeyPath(keyPath))
        
        guard self.next?.environment(keyPath) == nil else { return }
        self.next?.willSet(keyPath)
    }
    
    public func didSet<Member>(_ keyPath: WritableKeyPath<ScreenContext, Member>) {
        self._$observationRegistrar.didSet(self, keyPath: transformKeyPath(keyPath))
        
        guard self.next?.environment(keyPath) == nil else { return }
        self.next?.didSet(keyPath)
    }
    
    public func updatePreferenceAction<K: NavigationValues.PreferenceKey>(
        _ key: K.Type,
        action: @escaping (K.Value, K.Backward) -> Void
    ) where K.Value : Equatable {
        preferenceActions[ObjectIdentifier(K.self)] = { anyValue, backward in
            guard let value = anyValue as? K.Value else { return }
            action(value, { v in
                backward(v as Any)
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
    
    open func top() -> ScreenContext {
        guard let lastChild = children.last else { return self }
        return lastChild.top()
    }
    
    open func isParent(of child: ScreenContext) -> Bool {
       return children.contains(where: { $0 === child })
    }
    
    open func cleanup() {
        environments.dict.removeAll()
        preferences.removeAll()
        preferenceActions.removeAll()
    }
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

extension ScreenContext {
    public func head() -> ScreenContext? {
        var result: ScreenContext? = self
        while let previous = result?.previous {
            result = previous
        }
        return result
    }

    public  func tail() -> ScreenContext? {
        var result: ScreenContext? = self
        while let next = result?.next{
            result = next
        }
        return result
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
