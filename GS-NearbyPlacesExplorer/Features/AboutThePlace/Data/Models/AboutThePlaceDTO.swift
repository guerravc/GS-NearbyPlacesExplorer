// 
//  AboutThePlaceDTO.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Data Transfer Object for `AboutThePlaceEntity`.
///
/// This type mirrors the domain entity fields and adds `Codable` conformance
/// for JSON serialization. The domain `AboutThePlaceEntity` remains
/// free of serialization concerns.
///
/// Use `toDomain()` to convert to the domain entity, and `init(entity:)` to
/// convert a domain entity back to a DTO for encoding.
nonisolated public struct AboutThePlaceEntityDTO: Codable, Sendable {
  /// Entity identifier.
  public let id: UUID
  /// Display name.
  public let name: String
  /// Detail or level property.
  public let detail: String

  /// Creates a new instance of `AboutThePlaceEntityDTO`.
  /// - Parameters:
  ///   - id: Unique identifier of the entity.
  ///   - name: Display name of the entity.
  ///   - detail: Additional detail associated with the entity.
  public init(id: UUID, name: String, detail: String) {
    self.id = id
    self.name = name
    self.detail = detail
  }

  /// Creates a DTO from a domain entity.
  /// - Parameter entity: Domain entity to convert.
  public init(entity: AboutThePlaceEntity) {
    self.id = entity.id
    self.name = entity.name
    self.detail = entity.detail
  }

  /// Maps this DTO to the corresponding domain entity.
  public func toDomain() -> AboutThePlaceEntity {
    AboutThePlaceEntity(id: id, name: name, detail: detail)
  }
}

/// Data Transfer Object for the response envelope of the AboutThePlace module.
///
/// This type wraps `AboutThePlaceEntityDTO` and is decoded directly from
/// the backend JSON. Use `toDomain()` to convert to the domain response.
nonisolated public struct AboutThePlaceResponseDTO: Codable, Sendable {
  /// The entity DTO as received from the backend.
  public let entity: AboutThePlaceEntityDTO
  /// Additional numeric value from the backend.
  public let extraValue: Int

  /// Creates a new instance of `AboutThePlaceResponseDTO`.
  /// - Parameters:
  ///   - entity: The entity DTO from the backend.
  ///   - extraValue: Additional numeric value associated with the response.
  public init(entity: AboutThePlaceEntityDTO, extraValue: Int) {
    self.entity = entity
    self.extraValue = extraValue
  }

  /// Maps this DTO to the corresponding domain response.
  public func toDomain() -> AboutThePlaceResponse {
    AboutThePlaceResponse(
      entity: entity.toDomain(),
      extraValue: extraValue
    )
  }
}
