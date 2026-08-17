// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  CheckFavoriteStatusUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Input parameters for ``CheckFavoriteStatusUC``.
public struct CheckFavoriteStatusInput: Sendable {
    /// OSM element identifier of the place.
    public let osmId: Int
    /// Email of the authenticated user whose favorites list is queried.
    public let userEmail: String
    
    public init(osmId: Int, userEmail: String) {
        self.osmId = osmId
        self.userEmail = userEmail
    }
}

/// Async use case that checks whether a given place is in the current user's favorites.
///
/// Returns `true` if the place is saved as a favorite, `false` otherwise.
public protocol CheckFavoriteStatusUC: AsyncOperationUseCase where Input == CheckFavoriteStatusInput, Output == Bool {}

/// Default implementation of ``CheckFavoriteStatusUC``.
///
/// Delegates to ``FavoritePlacesGateway`` to query the local SwiftData store.
public final class CheckFavoriteStatusUCImpl: CheckFavoriteStatusUC, @unchecked Sendable {
    @Inject private var gateway: FavoritePlacesGateway
    
    public init() {}
    
    /// Executes the use case.
    /// - Parameter input: The place ID and user email to check.
    /// - Returns: A result with `true` if favorite, `false` otherwise, or an error.
    public func execute(_ input: CheckFavoriteStatusInput) async -> Result<Bool, Error> {
        do {
            let isFavorite = try await gateway.isFavorite(osmId: input.osmId, userEmail: input.userEmail)
            return .success(isFavorite)
        } catch {
            return .failure(error)
        }
    }
}
