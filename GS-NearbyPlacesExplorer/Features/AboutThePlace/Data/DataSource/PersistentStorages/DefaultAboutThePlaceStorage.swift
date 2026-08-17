// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  DefaultAboutThePlaceStorage.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Internal reference-type wrapper that allows `AboutThePlaceEntity` (a value type)
/// to be stored inside `NSCache`, which requires class keys and values.
private final class AboutThePlaceEntityWrapper: @unchecked Sendable {
    let entity: AboutThePlaceEntity
    init(entity: AboutThePlaceEntity) {
        self.entity = entity
    }
}

/// In-memory cache implementation of ``AboutThePlaceLocalDataSource``.
///
/// Stores place entities in an `NSCache` for the duration of the app session,
/// preventing redundant Overpass API calls when the user re-opens the same place.
/// Thread safety is provided by an `NSLock`.
public final class DefaultAboutThePlaceStorage: AboutThePlaceLocalDataSource, @unchecked Sendable {
    private let cache = NSCache<NSNumber, AboutThePlaceEntityWrapper>()
    private let lock = NSLock()
    
    public init() {}
    
    /// Returns the cached entity for the given OSM element ID, or `nil` if not in cache.
    /// - Parameter osmId: The unique OSM element ID to look up.
    public func getPlaceDetails(osmId: Int) async -> AboutThePlaceEntity? {
        let key = NSNumber(value: osmId)
        return lock.withLock {
            cache.object(forKey: key)?.entity
        }
    }
    
    /// Stores the given entity in the in-memory cache, keyed by its OSM element ID.
    /// - Parameter entity: The entity to cache.
    public func savePlaceDetails(_ entity: AboutThePlaceEntity) async {
        let key = NSNumber(value: entity.osmId)
        lock.withLock {
            cache.setObject(AboutThePlaceEntityWrapper(entity: entity), forKey: key)
        }
    }
}
