// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  FavoritePlacesGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Abstraction for local persistence of a user's favorite places.
///
/// Implemented by ``DefaultFavoritePlacesRepository``, which delegates to a SwiftData–backed local data source.
public protocol FavoritePlacesGateway: Sendable {

    /// Checks whether the given place is in the user's favorites list.
    ///
    /// - Parameters:
    ///   - osmId: OSM element identifier of the place.
    ///   - userEmail: Email of the authenticated user.
    /// - Returns: `true` if the place is a favorite of the given user.
    /// - Throws: An error if the local data source fails.
    func isFavorite(osmId: Int, userEmail: String) async throws -> Bool

    /// Adds the place to favorites if it is not already saved, or removes it if it is.
    ///
    /// - Parameter entity: The favorite place entity to toggle.
    /// - Throws: An error if the local data source fails.
    func toggleFavorite(entity: FavoritePlaceEntity) async throws
}
