//
//  DefaultAboutThePlaceRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public final class DefaultAboutThePlaceRepository: AboutThePlaceGateway, @unchecked Sendable {
    @Inject private var remoteDataSource: AboutThePlaceRemoteDataSource
    @Inject private var localDataSource: AboutThePlaceLocalDataSource
    
    public init() {}
    
    public func fetchPlaceDetails(osmId: Int) async throws -> AboutThePlaceEntity {
        if let cached = await localDataSource.getPlaceDetails(osmId: osmId) {
            return cached
        }
        
        let element = try await remoteDataSource.fetchElementDetails(osmId: osmId)
        let entity = map(element: element)
        
        await localDataSource.savePlaceDetails(entity)
        
        return entity
    }
    
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
