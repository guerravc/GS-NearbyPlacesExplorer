// 
//  DefaultLoginRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Default implementation of the module gateway, backed by a remote service
/// and a local storage.
public final class DefaultLoginRepository: LoginGateway {

  /// The remote data source used to authenticate the user.
  @Inject var remoteDataSource: LoginRemoteDataSource
  /// The local data source used to persist the authentication token.
  @Inject var localDataSource: LoginLocalDataSource

  /// Initializes a new instance of `DefaultLoginRepository`.
  public init() {}

  /// Authenticates the user and saves the session token locally.
  /// - Parameter presenting: The view controller to present the authentication UI on.
  /// - Returns: A result containing the authenticated `LoginEntity` or an error.
  public func signIn(presenting: Any) async -> Result<LoginEntity, Error> {
    do {
      let dto = try await remoteDataSource.signIn(presenting: presenting)
      // Save token (using ID as a mock token since GoogleSignIn handles its own token)
      do {
        try localDataSource.saveToken(dto.id)
        return .success(dto.toDomain())
      } catch {
        await remoteDataSource.signOut()
        return .failure(error)
      }
    } catch {
      return .failure(error)
    }
  }

  /// Attempts to silently restore a previously authenticated session.
  /// Checks local storage first before calling the remote data source.
  /// - Returns: A result containing the restored `LoginEntity` or an error.
  public func restoreSignIn() async -> Result<LoginEntity, Error> {
    do {
      // Check if we have a token stored locally before calling remote
      guard let _ = try localDataSource.getToken() else {
          return .failure(AuthError.unknown)
      }
      
      let dto = try await remoteDataSource.restoreSignIn()
      return .success(dto.toDomain())
    } catch {
      return .failure(error)
    }
  }
}
