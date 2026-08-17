//
//  FavoritePlaceEntity.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public struct FavoritePlaceEntity: Sendable, Equatable {
    public let userEmail: String
    public let osmId: Int
    public let name: String
    
    public init(userEmail: String, osmId: Int, name: String) {
        self.userEmail = userEmail
        self.osmId = osmId
        self.name = name
    }
}
