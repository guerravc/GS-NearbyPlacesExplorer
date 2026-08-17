// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceEntity.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Core domain entity representing the detailed information of a specific place.
///
/// Produced by ``FetchPlaceDetailsUCImpl`` and consumed by ``AboutThePlaceViewModel``
/// to populate the detail screen.
public struct AboutThePlaceEntity: Sendable, Equatable {
    /// Unique OSM element identifier.
    public let osmId: Int
    /// Display name of the place as tagged in OSM.
    public let name: String
    /// Geographic coordinate of the place.
    public let coordinate: Coordinate
    /// OSM amenity category (e.g., "cafe"). May be `nil` if not tagged.
    public let amenity: String?
    /// Raw OSM `opening_hours` string (e.g., "Mo-Fr 08:00-20:00"). May be `nil`.
    public let openingHours: String?
    
    /// Geographic coordinate expressed as a latitude/longitude pair.
    public struct Coordinate: Sendable, Equatable {
        /// Latitude component.
        public let lat: Double
        /// Longitude component.
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
