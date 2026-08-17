//
//  FetchPlaceDetailsUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public protocol FetchPlaceDetailsUC: AsyncOperationUseCase where Input == Int, Output == AboutThePlaceEntity {}

public final class FetchPlaceDetailsUCImpl: FetchPlaceDetailsUC, @unchecked Sendable {
    @Inject private var gateway: AboutThePlaceGateway
    
    public init() {}
    
    public func execute(_ input: Int) async -> Result<AboutThePlaceEntity, Error> {
        do {
            let entity = try await gateway.fetchPlaceDetails(osmId: input)
            return .success(entity)
        } catch {
            return .failure(error)
        }
    }
}
