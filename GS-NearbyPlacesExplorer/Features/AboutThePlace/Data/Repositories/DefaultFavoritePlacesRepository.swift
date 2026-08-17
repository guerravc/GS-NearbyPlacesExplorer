// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  DefaultFavoritePlacesRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Default implementation of ``FavoritePlacesGateway``.
///
/// Acts as a thin pass-through to ``FavoritePlacesLocalDataSource``,
/// which persists data using SwiftData.
public final class DefaultFavoritePlacesRepository: FavoritePlacesGateway, @unchecked Sendable {
    @Inject private var localDataSource: FavoritePlacesLocalDataSource
    
    public init() {}
    
    /// Checks the local SwiftData store to see whether the place is in the user's favorites.
    /// - Parameters:
    ///   - osmId: OSM element identifier.
    ///   - userEmail: Email of the authenticated user.
    /// - Returns: `true` if the place is saved as a favorite.
    public func isFavorite(osmId: Int, userEmail: String) async throws -> Bool {
        try await localDataSource.isFavorite(osmId: osmId, userEmail: userEmail)
    }
    
    /// Toggles the favorite state of the given place in the local SwiftData store.
    /// - Parameter entity: The favorite place entity to add or remove.
    public func toggleFavorite(entity: FavoritePlaceEntity) async throws {
        try await localDataSource.toggleFavorite(entity: entity)
    }
}
