//
//  CheckFavoriteStatusUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public struct CheckFavoriteStatusInput: Sendable {
    public let osmId: Int
    public let userEmail: String
    
    public init(osmId: Int, userEmail: String) {
        self.osmId = osmId
        self.userEmail = userEmail
    }
}

public protocol CheckFavoriteStatusUC: AsyncOperationUseCase where Input == CheckFavoriteStatusInput, Output == Bool {}

public final class CheckFavoriteStatusUCImpl: CheckFavoriteStatusUC, @unchecked Sendable {
    @Inject private var gateway: FavoritePlacesGateway
    
    public init() {}
    
    public func execute(_ input: CheckFavoriteStatusInput) async -> Result<Bool, Error> {
        do {
            let isFavorite = try await gateway.isFavorite(osmId: input.osmId, userEmail: input.userEmail)
            return .success(isFavorite)
        } catch {
            return .failure(error)
        }
    }
}
