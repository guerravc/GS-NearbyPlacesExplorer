//
//  ToggleFavoritePlaceUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public protocol ToggleFavoritePlaceUC: AsyncCommandUseCase where Input == FavoritePlaceEntity {}

public final class ToggleFavoritePlaceUCImpl: ToggleFavoritePlaceUC, @unchecked Sendable {
    @Inject private var gateway: FavoritePlacesGateway
    
    public init() {}
    
    public func execute(_ input: FavoritePlaceEntity) async -> Result<Void, Error> {
        do {
            try await gateway.toggleFavorite(entity: input)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
