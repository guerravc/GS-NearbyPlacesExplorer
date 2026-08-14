// 
//  LoginDataSourceProtocol.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

// MARK: - Remote (Gateway -> RemoteDataSource)

/// Remote data source for the Login module.
///
/// This protocol defines operations that interact with backend services
/// (HTTP APIs, streaming endpoints, etc.). Concrete implementations should
/// live in the `Services` folder and use the Networking Core (`APIClient`,
/// `APIRequestDispatcher`, etc.) to perform network calls.
///
/// The method signatures included here are examples and should be customized
/// depending on the requirements of the module.
public protocol LoginRemoteDataSource: Sendable {

  /// Fetches data from the remote backend using the given request.
  ///
  /// - Parameter request: The request model with parameters required by the backend.
  /// - Returns: A `BaseResponse` wrapping the module-specific response DTO.
  /// - Throws: A `NetworkError` or decoding error.
  func fetch(
    _ request: LoginRequest
  ) async throws -> BaseResponse<LoginResponseDTO>

  /// Persists the given entity DTO on the remote backend (create, update, delete, etc.).
  ///
  /// - Parameter dto: The entity DTO to be sent to the backend.
  /// - Returns: An `EmptyBaseResponse` describing backend status and message.
  /// - Throws: A `NetworkError` or decoding error.
  func persist(
    _ dto: LoginEntityDTO
  ) async throws -> EmptyBaseResponse
}

// MARK: - Local (Gateway -> LocalDataSource)

/// Local data source for the Login module.
///
/// This protocol defines operations that interact with local storage mechanisms:
/// databases, caches, files, or UserDefaults. Concrete implementations should
/// live in the `PersistentStorages` folder.
///
/// The method signatures below are examples and should be modified according
/// to the persistence needs of each feature.
public protocol LoginLocalDataSource: Sendable {

  /// Loads a cached entity from local storage, if available.
  ///
  /// - Returns: A cached instance of the module entity, or `nil` if none exists.
  /// - Throws: An error if the read operation fails.
  func loadCachedEntity() async throws -> LoginEntity?

  /// Saves the given entity to local storage.
  ///
  /// - Parameter entity: The entity to persist locally.
  /// - Throws: An error if the write operation fails.
  func save(
    _ entity: LoginEntity
  ) async throws

  /// Clears any cached data associated with the module.
  ///
  /// - Throws: An error if the clear operation fails.
  func clearCache() async throws
}
