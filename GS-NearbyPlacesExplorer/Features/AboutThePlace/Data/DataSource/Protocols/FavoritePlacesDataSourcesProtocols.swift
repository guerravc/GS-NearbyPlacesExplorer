// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  FavoritePlacesDataSourcesProtocols.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Protocol for the local persistence data source of favorite places.
///
/// The default implementation uses SwiftData to store ``FavoritePlace`` models on-device.
public protocol FavoritePlacesLocalDataSource: Sendable {

    /// Returns whether the place identified by `osmId` is saved in `userEmail`'s favorites.
    /// - Parameters:
    ///   - osmId: OSM element identifier of the place.
    ///   - userEmail: Email of the authenticated user.
    /// - Returns: `true` if the place is a favorite of the given user.
    func isFavorite(osmId: Int, userEmail: String) async throws -> Bool

    /// Adds the entity to favorites if absent, or removes it if already present.
    /// - Parameter entity: The favorite place entity to toggle.
    func toggleFavorite(entity: FavoritePlaceEntity) async throws
}
