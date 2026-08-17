//
//  DefaultAboutThePlaceStorage.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

private final class AboutThePlaceEntityWrapper: @unchecked Sendable {
    let entity: AboutThePlaceEntity
    init(entity: AboutThePlaceEntity) {
        self.entity = entity
    }
}

public final class DefaultAboutThePlaceStorage: AboutThePlaceLocalDataSource, @unchecked Sendable {
    private let cache = NSCache<NSNumber, AboutThePlaceEntityWrapper>()
    private let lock = NSLock()
    
    public init() {}
    
    public func getPlaceDetails(osmId: Int) async -> AboutThePlaceEntity? {
        let key = NSNumber(value: osmId)
        return lock.withLock {
            cache.object(forKey: key)?.entity
        }
    }
    
    public func savePlaceDetails(_ entity: AboutThePlaceEntity) async {
        let key = NSNumber(value: entity.osmId)
        lock.withLock {
            cache.setObject(AboutThePlaceEntityWrapper(entity: entity), forKey: key)
        }
    }
}
