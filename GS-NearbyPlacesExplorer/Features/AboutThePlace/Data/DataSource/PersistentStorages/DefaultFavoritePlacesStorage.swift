//
//  DefaultFavoritePlacesStorage.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation
import SwiftData

@MainActor
public final class DefaultFavoritePlacesStorage: FavoritePlacesLocalDataSource {
    private var context: ModelContext {
        GS_NearbyPlacesExplorerApp.sharedModelContainer.mainContext
    }
    
    public init() {}
    
    public func isFavorite(osmId: Int, userEmail: String) async throws -> Bool {
        let fetchDescriptor = FetchDescriptor<FavoritePlace>(
            predicate: #Predicate { $0.osmId == osmId && $0.userEmail == userEmail }
        )
        let count = try context.fetchCount(fetchDescriptor)
        return count > 0
    }
    
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
