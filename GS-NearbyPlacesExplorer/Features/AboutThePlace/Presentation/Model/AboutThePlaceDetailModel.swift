//
//  AboutThePlaceDetailModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public struct AboutThePlaceDetailModel: Sendable, Equatable {
    public let osmId: Int
    public let name: String
    public let amenity: String
    public let openingHours: String
    public let coordinate: Coordinate
    
    public struct Coordinate: Sendable, Equatable {
        public let lat: Double
        public let lon: Double
        
        public init(lat: Double, lon: Double) {
            self.lat = lat
            self.lon = lon
        }
    }
    
    public init(osmId: Int, name: String, amenity: String, openingHours: String, coordinate: Coordinate) {
        self.osmId = osmId
        self.name = name
        self.amenity = amenity
        self.openingHours = openingHours
        self.coordinate = coordinate
    }
    
    public init(entity: AboutThePlaceEntity) {
        self.osmId = entity.osmId
        self.name = entity.name
        self.amenity = entity.amenity ?? "Not specified"
        self.openingHours = entity.openingHours ?? "Not specified"
        self.coordinate = Coordinate(lat: entity.coordinate.lat, lon: entity.coordinate.lon)
    }
}
