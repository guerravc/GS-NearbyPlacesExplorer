// 
//  DependencyContainer.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation
import os

/// A lightweight, thread-safe dependency injection container.
/// This container allows registration and resolution of dependencies by type
/// and optional name, without relying on external libraries.
/// Use this type as the central service graph for the application.
public final class DependencyContainer: @unchecked Sendable {
  // MARK: - Types

  /// A unique key used to identify a registered service entry.
  nonisolated private struct ServiceKey: Hashable, Sendable {
    /// The identifier of the service type.
    let type: ObjectIdentifier
    /// An optional registration name to distinguish multiple bindings of the same type.
    let name: String?
  }

  /// Represents a registered service entry in the container.
  private enum ServiceEntry: @unchecked Sendable {
    /// A pre-built instance that will be returned as-is.
    case instance(Any)
    /// A factory closure used to create new instances on demand.
    case factory(() -> Any)
  }

  // MARK: - Singleton

  /// Shared container instance used across the application.
  public static let shared = DependencyContainer()

  // MARK: - Internal state

  private let storage = OSAllocatedUnfairLock(
    initialState: [ServiceKey: ServiceEntry]()
  )

  // MARK: - Initializers

  /// Creates a new dependency container instance.
  /// - Note: Use `DependencyContainer.shared` for the shared application container.
  public init() { }

  // MARK: - Registration (instance)

  /// Registers a singleton instance for the given type and optional name.
  /// - Parameters:
  ///   - type: The type to associate with the instance.
  ///   - name: Optional registration name to distinguish multiple bindings of the same type.
  ///   - instance: The instance to register.
  /// - Returns: The container instance to allow method chaining.
  @discardableResult
  public func registerSingleton<T>(
    _ type: T.Type = T.self,
    name: String? = nil,
    _ instance: T
  ) -> Self {
    let key = ServiceKey(type: ObjectIdentifier(type), name: name)
    storage.withLock { $0[key] = .instance(instance) }
    return self
  }

  /// Registers a singleton instance for the given type and optional name
  /// in the shared container.
  /// - Parameters:
  ///   - type: The type to associate with the instance.
  ///   - name: Optional registration name to distinguish multiple bindings of the same type.
  ///   - instance: The instance to register.
  @discardableResult
  public static func registerSingleton<T>(
    _ type: T.Type = T.self,
    name: String? = nil,
    _ instance: T
  ) -> DependencyContainer {
    shared.registerSingleton(type, name: name, instance)
  }

  // MARK: - Registration (factory)

  /// Registers a factory closure for the given type and optional name.
  /// The factory is invoked each time the dependency is resolved.
  /// - Parameters:
  ///   - type: The type to associate with the factory.
  ///   - name: Optional registration name to distinguish multiple bindings of the same type.
  ///   - factory: A closure that produces a new instance of the dependency.
  /// - Returns: The container instance to allow method chaining.
  @discardableResult
  public func registerFactory<T>(
    _ type: T.Type = T.self,
    name: String? = nil,
    _ factory: @escaping () -> T
  ) -> Self {
    let key = ServiceKey(type: ObjectIdentifier(type), name: name)
    storage.withLock { $0[key] = .factory(factory) }
    return self
  }

  /// Registers a factory closure for the given type and optional name
  /// in the shared container.
  /// - Parameters:
  ///   - type: The type to associate with the factory.
  ///   - name: Optional registration name to distinguish multiple bindings of the same type.
  ///   - factory: A closure that produces a new instance of the dependency.
  @discardableResult
  public static func registerFactory<T>(
    _ type: T.Type = T.self,
    name: String? = nil,
    _ factory: @escaping () -> T
  ) -> DependencyContainer {
    shared.registerFactory(type, name: name, factory)
  }

  // MARK: - Resolving

  /// Resolves a dependency for the given type and optional name.
  /// - Parameters:
  ///   - type: The type of the dependency to resolve.
  ///   - name: Optional registration name used during registration.
  /// - Returns: The resolved dependency instance.
  /// - Note: This method will trigger a runtime error if no registration is found.
  public func resolve<T>(
    _ type: T.Type = T.self,
    name: String? = nil
  ) -> T {
    guard let resolved: T = resolveOptional(type, name: name) else {
      fatalError(
        """
        No dependency registered for type \(type)\(name.map { " (name: \($0))" } ?? "").
        Make sure you have registered the dependency before resolving it.
        """
      )
    }

    return resolved
  }

  /// Resolves an optional dependency for the given type and optional name.
  /// - Parameters:
  ///   - type: The type of the dependency to resolve.
  ///   - name: Optional registration name used during registration.
  /// - Returns: The resolved dependency instance, or `nil` if no registration is found.
  public func resolveOptional<T>(
    _ type: T.Type = T.self,
    name: String? = nil
  ) -> T? {
    let key = ServiceKey(type: ObjectIdentifier(type), name: name)
    let entry = storage.withLock { $0[key] }

    guard let serviceEntry = entry else {
      return nil
    }

    switch serviceEntry {
    case .instance(let any):
      return any as? T
    case .factory(let factory):
      return factory() as? T
    }
  }

  /// Resolves a dependency from the shared container.
  /// - Parameters:
  ///   - type: The type of the dependency to resolve.
  ///   - name: Optional registration name used during registration.
  /// - Returns: The resolved dependency instance.
  /// - Note: This method will trigger a runtime error if no registration is found.
  public static func resolve<T>(
    _ type: T.Type = T.self,
    name: String? = nil
  ) -> T {
    shared.resolve(type, name: name)
  }

  /// Resolves an optional dependency from the shared container.
  /// - Parameters:
  ///   - type: The type of the dependency to resolve.
  ///   - name: Optional registration name used during registration.
  /// - Returns: The resolved dependency instance, or `nil` if no registration is found.
  public static func resolveOptional<T>(
    _ type: T.Type = T.self,
    name: String? = nil
  ) -> T? {
    shared.resolveOptional(type, name: name)
  }

  // MARK: - Reset

  /// Removes all registered dependencies from the container.
  /// - Note: This method is intended for testing scenarios or when rebuilding
  ///   the service graph at runtime.
  public func reset() {
    storage.withLock { $0.removeAll() }
  }

  /// Removes all registered dependencies from the shared container.
  /// - Note: This method is intended for testing scenarios or when rebuilding
  ///   the service graph at runtime.
  public static func reset() {
    shared.reset()
  }
}
