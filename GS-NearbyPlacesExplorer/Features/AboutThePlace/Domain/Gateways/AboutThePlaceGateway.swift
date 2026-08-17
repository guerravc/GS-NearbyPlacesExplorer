// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Abstraction for data access of the AboutThePlace module.
///
/// Implemented by ``DefaultAboutThePlaceRepository``, which applies a cache-then-network strategy.
public protocol AboutThePlaceGateway: Sendable {

    /// Fetches the full details of a place by its OSM element identifier.
    ///
    /// - Parameter osmId: The unique OSM element ID.
    /// - Returns: A populated ``AboutThePlaceEntity``.
    /// - Throws: An error if the network request fails or the element is not found.
    func fetchPlaceDetails(osmId: Int) async throws -> AboutThePlaceEntity
}
