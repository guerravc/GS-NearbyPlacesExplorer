//
//  AboutThePlaceEntity.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public struct AboutThePlaceEntity: Sendable, Equatable {
    public let osmId: Int
    public let name: String
    public let coordinate: Coordinate
    public let amenity: String?
    public let openingHours: String?
    
    public struct Coordinate: Sendable, Equatable {
        public let lat: Double
        public let lon: Double
        
        public init(lat: Double, lon: Double) {
            self.lat = lat
            self.lon = lon
        }
    }
    
    public init(osmId: Int, name: String, coordinate: Coordinate, amenity: String?, openingHours: String?) {
        self.osmId = osmId
        self.name = name
        self.coordinate = coordinate
        self.amenity = amenity
        self.openingHours = openingHours
    }
}
