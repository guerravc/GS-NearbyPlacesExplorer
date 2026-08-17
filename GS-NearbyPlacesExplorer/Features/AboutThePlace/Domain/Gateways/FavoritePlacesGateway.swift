//
//  FavoritePlacesGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public protocol FavoritePlacesGateway: Sendable {
    func isFavorite(osmId: Int, userEmail: String) async throws -> Bool
    func toggleFavorite(entity: FavoritePlaceEntity) async throws
}
