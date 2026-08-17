// 
//  LoginGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Abstraction for data access of the Login module.
///
/// This gateway defines the contract used by the domain layer (use cases)
/// to interact with data sources (remote and/or local) for authentication.
public protocol LoginGateway: Sendable {

  /// Indicates whether a locally persisted session is available for restoration.
  func hasStoredSession() -> Bool
  
  /// Authenticates the user.
  ///
  /// - Parameter presenting: The presenting view controller (e.g. for Google Sign In).
  /// - Returns: A result containing the authenticated `LoginEntity` or an error.
  func signIn(
    presenting: Any
  ) async -> Result<LoginEntity, Error>
  
  /// Attempts to restore a previous session.
  ///
  /// - Returns: A result containing the authenticated `LoginEntity` or an error.
  func restoreSignIn() async -> Result<LoginEntity, Error>
}
