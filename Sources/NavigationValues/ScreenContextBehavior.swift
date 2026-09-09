//
//  ScreenContextBehavior.swift
//  NavigationValues
//
//  Created by TangTao on 2026/9/6.
//

import SwiftUI

/// A behavior that extends a ``ScreenContext`` with additional capabilities through composition.
///
/// `ScreenContext` is a final type. Instead of subclassing it, attach a behavior to
/// customize how the context reacts to lifecycle events:
///
///     struct MyBehavior: ScreenContextBehavior {
///         func context(_ context: ScreenContext, didAttachTo parent: ScreenContext) {
///             // React when this context appears under a parent in the view hierarchy.
///         }
///     }
///
///     extension ScreenContextBehavior where Self == MyBehavior {
///         static var myBehavior: MyBehavior { MyBehavior() }
///     }
///
///     .screenContext(.myBehavior)
///
/// Behaviors are invoked on the main actor and receive the context as a parameter,
/// so a behavior does not need to (and should not) retain the context it extends.
///
/// - Note: All hooks must be **idempotent** — they may be called multiple times
///   as the view hierarchy recomputes. Guard against repeated application, e.g. by
///   checking whether the desired state is already in place.
@MainActor
public protocol ScreenContextBehavior {
    /// The role this behavior stamps onto its ``ScreenContext``.
    ///
    /// Copied onto the context when it attaches. The default is ``ScreenContext/Role/screen``.
    /// Override to advertise a role, such as ``ScreenContext/Role/navigationStack``.
    var role: ScreenContext.Role { get }
    
    /// Called after the context's ``ScreenContext/children`` are collected from
    /// the view hierarchy.
    ///
    /// Preference values bubble up from descendants; the modifier assigns
    /// ``ScreenContext/children`` first, then invokes this hook so the behavior
    /// can relink siblings (for example, wiring ``ScreenContext/previous`` and
    /// ``ScreenContext/next``).
    /// - Parameters:
    ///   - context: The context whose children changed.
    ///   - children: The new children, in view-hierarchy order.
    func context(_ context: ScreenContext, didUpdateChildren children: [ScreenContext])
    
    /// Called when this context appears in the view hierarchy, before it is
    /// reflected in the parent's ``ScreenContext/children``.
    ///
    /// The modifier assigns ``ScreenContext/parent`` first, then invokes this
    /// hook so the behavior can add linking on top (for example, wiring
    /// ``ScreenContext/previous`` to the parent's last child).
    /// - Parameters:
    ///   - context: The context that just attached.
    ///   - parent: The parent context it attached to.
    func context(_ context: ScreenContext, didAttachTo parent: ScreenContext)
}

public extension ScreenContextBehavior {
    var role: ScreenContext.Role { .screen }
    func context(_ context: ScreenContext, didUpdateChildren children: [ScreenContext]) { }
    func context(_ context: ScreenContext, didAttachTo parent: ScreenContext) { }
}

public extension ScreenContextBehavior where Self == NavigationScreenBehavior {
    static var navigation: NavigationScreenBehavior {
        NavigationScreenBehavior()
    }
}

public extension ScreenContextBehavior where Self == NavigationStackBehavior {
    static var navigationStack: NavigationStackBehavior {
        NavigationStackBehavior()
    }
}

public extension ScreenContextBehavior where Self == DefaultScreenContextBehavior {
    static var screen: DefaultScreenContextBehavior {
        DefaultScreenContextBehavior()
    }
}






public struct DefaultScreenContextBehavior: ScreenContextBehavior {
    init() { }
}

public struct NavigationStackBehavior: ScreenContextBehavior {
    init() { }
    
    public var role: ScreenContext.Role { .navigationStack }
    
    public func context(_ context: ScreenContext, didUpdateChildren children: [ScreenContext]) {
        for (previous, next) in zip(children, children.dropFirst(1)) {
            previous.next = next
            next.previous = previous
        }
    }
}

public struct NavigationScreenBehavior: ScreenContextBehavior {
    init() { }
    
    public func context(_ context: ScreenContext, didAttachTo parent: ScreenContext) {
        // Skip once this context is already collected as a child; that also
        // prevents linking a context to itself when the hierarchy recomputes.
        guard parent.isParent(of: context) == false else { return }
        context.previous = parent.children.last
    }
}

