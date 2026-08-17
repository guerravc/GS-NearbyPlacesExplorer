//
//  DefaultFavoritePlacesRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public final class DefaultFavoritePlacesRepository: FavoritePlacesGateway, @unchecked Sendable {
    @Inject private var localDataSource: FavoritePlacesLocalDataSource
    
    public init() {}
    
    public func isFavorite(osmId: Int, userEmail: String) async throws -> Bool {
        try await localDataSource.isFavorite(osmId: osmId, userEmail: userEmail)
    }
    
    public func toggleFavorite(entity: FavoritePlaceEntity) async throws {
        try await localDataSource.toggleFavorite(entity: entity)
    }
}
