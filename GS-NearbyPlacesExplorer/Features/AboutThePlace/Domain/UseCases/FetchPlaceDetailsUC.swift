// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  FetchPlaceDetailsUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Async use case that retrieves the full details of a place identified by its OSM ID.
///
/// Returns ``AboutThePlaceEntity`` on success, with caching handled by the repository layer.
public protocol FetchPlaceDetailsUC: AsyncOperationUseCase where Input == Int, Output == AboutThePlaceEntity {}

/// Default implementation of ``FetchPlaceDetailsUC``.
///
/// Delegates to ``AboutThePlaceGateway``, which applies a cache-then-network strategy.
public final class FetchPlaceDetailsUCImpl: FetchPlaceDetailsUC, @unchecked Sendable {
    @Inject private var gateway: AboutThePlaceGateway
    
    public init() {}
    
    /// Executes the use case.
    /// - Parameter input: OSM element ID of the place to fetch.
    /// - Returns: A result containing the entity or an error.
    public func execute(_ input: Int) async -> Result<AboutThePlaceEntity, Error> {
        do {
            let entity = try await gateway.fetchPlaceDetails(osmId: input)
            return .success(entity)
        } catch {
            return .failure(error)
        }
    }
}
