// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  FavoritePlaceEntity.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Domain entity representing a place that a specific user has marked as a favorite.
///
/// Used as input for ``ToggleFavoritePlaceUC`` and persisted locally via SwiftData through ``DefaultFavoritePlacesStorage``.
public struct FavoritePlaceEntity: Sendable, Equatable {
    /// Email of the authenticated user who owns this favorite.
    public let userEmail: String
    /// OSM element identifier of the favorited place.
    public let osmId: Int
    /// Display name of the favorited place.
    public let name: String

    /// Creates a new `FavoritePlaceEntity`.
    /// - Parameters:
    ///   - userEmail: Email of the authenticated user.
    ///   - osmId: OSM element identifier.
    ///   - name: Display name of the place.
    public init(userEmail: String, osmId: Int, name: String) {
        self.userEmail = userEmail
        self.osmId = osmId
        self.name = name
    }
}
