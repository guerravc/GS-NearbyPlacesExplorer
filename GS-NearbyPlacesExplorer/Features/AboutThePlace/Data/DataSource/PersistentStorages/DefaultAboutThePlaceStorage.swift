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
        lock.lock()
        defer { lock.unlock() }
        
        return cache.object(forKey: key)?.entity
    }
    
    public func savePlaceDetails(_ entity: AboutThePlaceEntity) async {
        let key = NSNumber(value: entity.osmId)
        lock.lock()
        defer { lock.unlock() }
        
        cache.setObject(AboutThePlaceEntityWrapper(entity: entity), forKey: key)
    }
}
