// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  DefaultFavoritePlacesStorage.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation
import SwiftData

/// SwiftData–backed implementation of ``FavoritePlacesLocalDataSource``.
///
/// Reads and writes ``FavoritePlace`` model objects using the shared `ModelContainer`
/// on the main context. Runs on `@MainActor` to match SwiftData's threading requirements.
@MainActor
public final class DefaultFavoritePlacesStorage: FavoritePlacesLocalDataSource {
    private var context: ModelContext {
        GS_NearbyPlacesExplorerApp.sharedModelContainer.mainContext
    }
    
    public init() {}
    
    /// Queries the SwiftData store for a favorite matching the given OSM element ID and user email.
    /// - Parameters:
    ///   - osmId: OSM element identifier of the place.
    ///   - userEmail: Email of the authenticated user.
    /// - Returns: `true` if a matching `FavoritePlace` record exists.
    public func isFavorite(osmId: Int, userEmail: String) async throws -> Bool {
        let fetchDescriptor = FetchDescriptor<FavoritePlace>(
            predicate: #Predicate { $0.osmId == osmId && $0.userEmail == userEmail }
        )
        let count = try context.fetchCount(fetchDescriptor)
        return count > 0
    }
    
    /// Inserts or deletes a `FavoritePlace` record in the SwiftData store.
    ///
    /// If a record with the same `osmId` and `userEmail` already exists, it is deleted (remove from favorites).
    /// Otherwise, a new record is inserted (add to favorites).
    ///
    /// - Parameter entity: The favorite place entity to toggle.
    /// - Throws: An error if the SwiftData fetch, delete, insert, or save fails.
    public func toggleFavorite(entity: FavoritePlaceEntity) async throws {
        let osmId = entity.osmId
        let userEmail = entity.userEmail
        
        let fetchDescriptor = FetchDescriptor<FavoritePlace>(
            predicate: #Predicate { $0.osmId == osmId && $0.userEmail == userEmail }
        )
        let existing = try context.fetch(fetchDescriptor)
        
        if let place = existing.first {
            context.delete(place)
        } else {
            let newPlace = FavoritePlace(userEmail: entity.userEmail, osmId: entity.osmId, name: entity.name)
            context.insert(newPlace)
        }
        try context.save()
    }
}
