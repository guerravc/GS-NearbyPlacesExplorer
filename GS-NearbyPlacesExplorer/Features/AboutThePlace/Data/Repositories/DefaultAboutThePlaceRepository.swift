// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  DefaultAboutThePlaceRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Default implementation of ``AboutThePlaceGateway``.
///
/// Applies a cache-then-network strategy: checks the local data source first,
/// fetches from the remote API if not cached, then saves the result locally.
public final class DefaultAboutThePlaceRepository: AboutThePlaceGateway, @unchecked Sendable {
    @Inject private var remoteDataSource: AboutThePlaceRemoteDataSource
    @Inject private var localDataSource: AboutThePlaceLocalDataSource
    
    public init() {}
    
    /// Fetches place details, using the local cache when available.
    ///
    /// - Parameter osmId: The OSM element ID of the place.
    /// - Returns: A fully populated ``AboutThePlaceEntity``.
    /// - Throws: An error if the remote request or decoding fails.
    public func fetchPlaceDetails(osmId: Int) async throws -> AboutThePlaceEntity {
        if let cached = await localDataSource.getPlaceDetails(osmId: osmId) {
            return cached
        }
        
        let element = try await remoteDataSource.fetchElementDetails(osmId: osmId)
        let entity = map(element: element)
        
        await localDataSource.savePlaceDetails(entity)
        
        return entity
    }
    
    /// Maps a raw ``OSMElement`` returned by the Overpass API to a domain entity.
    ///
    /// Falls back to the element's `center` coordinate when `lat`/`lon` are absent (ways/relations).
    /// - Parameter element: Raw OSM element to map.
    /// - Returns: A ``AboutThePlaceEntity`` populated from the element's tags and coordinates.
    private func map(element: OSMElement) -> AboutThePlaceEntity {
        let lat = element.lat ?? element.center?.lat ?? 0.0
        let lon = element.lon ?? element.center?.lon ?? 0.0
        
        return AboutThePlaceEntity(
            osmId: element.id,
            name: element.tags?.name ?? "Unknown",
            coordinate: AboutThePlaceEntity.Coordinate(lat: lat, lon: lon),
            amenity: element.tags?.amenity,
            openingHours: element.tags?.openingHours
        )
    }
}
