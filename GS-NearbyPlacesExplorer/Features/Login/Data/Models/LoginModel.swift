// 
//  LoginDTO.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Data Transfer Object for `LoginEntity`.
nonisolated public struct LoginModel: Codable, Sendable {
  /// The unique identifier of the user.
  public let id: String
  /// The full name of the user.
  public let name: String
  /// The email address of the user.
  public let email: String
  /// An optional URL for the user's profile image.
  public let profileImageURL: URL?

  /// Initializes a new `LoginModel`.
  /// - Parameters:
  ///   - id: The unique identifier.
  ///   - name: The user's full name.
  ///   - email: The user's email address.
  ///   - profileImageURL: The optional profile image URL.
  public init(id: String, name: String, email: String, profileImageURL: URL?) {
    self.id = id
    self.name = name
    self.email = email
    self.profileImageURL = profileImageURL
  }

  /// Creates a DTO from a domain entity.
  public init(entity: LoginEntity) {
    self.id = entity.id
    self.name = entity.name
    self.email = entity.email
    self.profileImageURL = entity.profileImageURL
  }

  /// Maps this DTO to the corresponding domain entity.
  public func toDomain() -> LoginEntity {
    LoginEntity(id: id, name: name, email: email, profileImageURL: profileImageURL)
  }
}
