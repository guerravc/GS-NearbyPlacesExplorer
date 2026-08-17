// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceDataSourcesProtocols.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// In-memory or on-disk cache for place detail data within the AboutThePlace module.
///
/// The default implementation stores entities in memory for the duration of the app session.
public protocol AboutThePlaceLocalDataSource: Sendable {

    /// Returns the cached entity for the given OSM element ID, or `nil` if not cached.
    /// - Parameter osmId: The unique OSM element ID to look up.
    func getPlaceDetails(osmId: Int) async -> AboutThePlaceEntity?

    /// Persists the given entity so subsequent calls to `getPlaceDetails` can avoid network round-trips.
    /// - Parameter entity: The entity to store.
    func savePlaceDetails(_ entity: AboutThePlaceEntity) async
}

/// Remote data source for the AboutThePlace module.
///
/// Implemented by ``DefaultAboutThePlaceService``, which queries the Overpass API.
public protocol AboutThePlaceRemoteDataSource: Sendable {

    /// Fetches a single OSM element from the Overpass API by its identifier.
    ///
    /// - Parameter osmId: Unique OSM element ID.
    /// - Returns: The matching ``OSMElement``.
    /// - Throws: A ``NetworkError`` or an `NSError` (code 404) when the element is absent.
    func fetchElementDetails(osmId: Int) async throws -> OSMElement
}
