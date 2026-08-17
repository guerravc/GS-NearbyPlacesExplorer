// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  LoginEntity.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Core domain entity for the Login module representing the authenticated user.
public struct LoginEntity: Equatable, Sendable {
  /// The unique identifier of the user.
  public let id: String
  /// The full name of the user.
  public let name: String
  /// The email address of the user.
  public let email: String
  /// An optional URL for the user's profile image.
  public let profileImageURL: URL?

  /// Initializes a new `LoginEntity`.
  /// - Parameters:
  ///   - id: The unique identifier.
  ///   - name: The user's full name.
  ///   - email: The user's email address.
  ///   - profileImageURL: The optional profile image URL.
  nonisolated public init(
    id: String,
    name: String,
    email: String,
    profileImageURL: URL?
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.profileImageURL = profileImageURL
  }
}
