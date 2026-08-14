// 
//  AboutThePlaceGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Abstraction for data access of the AboutThePlace module.
///
/// This gateway defines the contract used by the domain layer (use cases)
/// to interact with data sources (remote and/or local).
/// Concrete implementations live in the Data layer and should not leak
/// infrastructure details (networking, persistence, etc.) into the domain.
public protocol AboutThePlaceGateway: Sendable {
  /// Fetches the main entity for the given request.
  ///
  /// - Parameter request: Request model containing the parameters required
  ///   to retrieve the entity.
  /// - Returns: A result containing the response model on success or an error
  ///   describing the failure.
  func fetch(
    _ request: AboutThePlaceRequest
  ) async -> Result<AboutThePlaceResponse, Error>
  
  /// Performs an update or command operation for the given entity.
  ///
  /// This method is intended for write operations (create, update, delete)
  /// related to the module entity.
  ///
  /// - Parameter entity: The entity to be persisted or used as input
  ///   for the command operation.
  /// - Returns: A result indicating success or failure of the operation.
  func persist(
    _ entity: AboutThePlaceEntity
  ) async -> Result<Void, Error>
}