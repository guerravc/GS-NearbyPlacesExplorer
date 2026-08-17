// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceDetailModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Presentation model for the AboutThePlace detail screen.
///
/// Maps optional fields from ``AboutThePlaceEntity`` to non-optional strings
/// with sensible defaults, making the view layer simpler.
public struct AboutThePlaceDetailModel: Sendable, Equatable {
    /// OSM element identifier.
    public let osmId: Int
    /// Display name of the place.
    public let name: String
    /// Human-readable amenity category (e.g., "Cafetería").
    public let amenity: String
    /// Opening hours string (e.g., "Mo-Fr 08:00-20:00").
    public let openingHours: String
    /// Geographic coordinate of the place.
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
    
    /// Convenience initializer that maps an ``AboutThePlaceEntity`` to this model.
    ///
    /// Optional entity fields default to `"Not specified"` when absent.
    /// - Parameter entity: The domain entity to map from.
    public init(entity: AboutThePlaceEntity) {
        self.osmId = entity.osmId
        self.name = entity.name
        self.amenity = entity.amenity ?? "Not specified"
        self.openingHours = entity.openingHours ?? "Not specified"
        self.coordinate = Coordinate(lat: entity.coordinate.lat, lon: entity.coordinate.lon)
    }
}
