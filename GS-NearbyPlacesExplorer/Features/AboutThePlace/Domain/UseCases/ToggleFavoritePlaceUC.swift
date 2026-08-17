// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  ToggleFavoritePlaceUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Async use case that adds or removes a place from the user's favorites.
///
/// If the place is already saved, it is removed; otherwise, it is added.
/// Delegates to ``FavoritePlacesGateway``.
public protocol ToggleFavoritePlaceUC: AsyncCommandUseCase where Input == FavoritePlaceEntity {}

/// Default implementation of ``ToggleFavoritePlaceUC``.
///
/// Delegates to ``FavoritePlacesGateway`` to perform the toggle in the local SwiftData store.
public final class ToggleFavoritePlaceUCImpl: ToggleFavoritePlaceUC, @unchecked Sendable {
    @Inject private var gateway: FavoritePlacesGateway
    
    public init() {}
    
    /// Executes the toggle operation.
    /// - Parameter input: The favorite place entity representing the place and user.
    /// - Returns: A result indicating success or failure.
    public func execute(_ input: FavoritePlaceEntity) async -> Result<Void, Error> {
        do {
            try await gateway.toggleFavorite(entity: input)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
