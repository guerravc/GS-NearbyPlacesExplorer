// 
//  DIWrappers.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Property wrapper that resolves a dependency from the shared dependency container.
/// Use this wrapper in any type that needs access to a registered service.
/// The dependency is resolved lazily on first access and then cached.
/// - Important: If the dependency has not been registered beforehand,
///   a runtime `fatalError` will be triggered.
@propertyWrapper
public struct Inject<T> {
  /// Optional registration name used to distinguish multiple bindings of the same type.
  private let name: String?

  /// Cached resolved dependency instance.
  private var cachedValue: T?

  /// Creates a new `Inject` wrapper.
  /// - Parameter name: Optional registration name used during registration.
  public init(name: String? = nil) {
    self.name = name
  }

  /// The resolved dependency instance.
  /// Resolved once and then cached.
  public var wrappedValue: T {
    mutating get {
      if let value = cachedValue {
        return value
      }
      
      let resolved: T = DependencyContainer.resolve(T.self, name: name)
      cachedValue = resolved
      return resolved
    }
    set {
      cachedValue = newValue
    }
  }
}

/// Property wrapper that registers a dependency instance in the shared dependency container.
/// Use this wrapper at the composition root to provide concrete implementations
/// for protocols or types used throughout the application.
/// - Note: The wrapper registers the wrapped value as a singleton.
@propertyWrapper
public struct Provider<T> {
  /// Backing value of the provided dependency.
  private let value: T

  /// Creates the wrapper and registers the provided value in the shared container.
  /// - Parameters:
  ///   - wrappedValue: Instance to register.
  ///   - name: Optional registration name to distinguish multiple bindings of the same type.
  public init(
    wrappedValue: T,
    name: String? = nil
  ) {
    self.value = wrappedValue
    DependencyContainer.registerSingleton(T.self, name: name, wrappedValue)
  }

  /// Exposes the provided instance.
  public var wrappedValue: T {
    value
  }
}