// 
//  LoginDataSourceProtocol.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

// MARK: - Remote (Gateway -> RemoteDataSource)

/// Remote data source for the Login module.
public protocol LoginRemoteDataSource: Sendable {

  /// Authenticates the user remotely.
  ///
  /// - Parameter presenting: The presenting view controller.
  /// - Returns: A DTO representing the user.
  /// - Throws: An error if authentication fails.
  func signIn(
    presenting: Any
  ) async throws -> LoginModel

  /// Restores a previously authenticated session remotely.
  ///
  /// - Returns: A DTO representing the user.
  /// - Throws: An error if restoration fails.
  func restoreSignIn() async throws -> LoginModel

  /// Signs the user out remotely.
  func signOut() async
}

// MARK: - Local (Gateway -> LocalDataSource)

/// Local data source for the Login module.
public protocol LoginLocalDataSource: Sendable {

  /// Saves the given token to local storage.
  ///
  /// - Parameter token: The authentication token to persist.
  /// - Throws: An error if the write operation fails.
  func saveToken(_ token: String) throws

  /// Loads the cached token from local storage, if available.
  ///
  /// - Returns: The cached token, or `nil` if none exists.
  /// - Throws: An error if the read operation fails.
  func getToken() throws -> String?

  /// Clears any cached token.
  ///
  /// - Throws: An error if the clear operation fails.
  func deleteToken() throws
}
