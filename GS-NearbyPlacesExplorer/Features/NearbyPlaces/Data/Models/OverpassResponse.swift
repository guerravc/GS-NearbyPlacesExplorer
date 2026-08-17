// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  OverpassResponse.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Top-level response returned by the Overpass API.
/// Contains a list of OSM elements that match the query.
public struct OverpassResponse: Decodable, Sendable {
    /// Array of OSM elements (nodes, ways, or relations) returned by the query.
    public let elements: [OSMElement]
}

/// Represents a single OSM element (node, way, or relation) returned by the Overpass API.
public struct OSMElement: Decodable, Sendable {
    /// Type of the element: "node", "way", or "relation".
    public let type: String
    /// Unique OSM identifier of the element.
    public let id: Int
    /// Latitude of the element. Present only for nodes.
    public let lat: Double?
    /// Longitude of the element. Present only for nodes.
    public let lon: Double?
    /// Geometric center of the element. Present for ways when `out center` is requested.
    public let center: OSMCenter?
    /// Key-value tags associated with the element (name, amenity, opening_hours, etc.).
    public let tags: OSMTags?
}

/// The computed geographic center of an OSM way or relation.
public struct OSMCenter: Decodable, Sendable {
    /// Latitude of the center point.
    public let lat: Double
    /// Longitude of the center point.
    public let lon: Double
}

/// Key-value tags attached to an OSM element, decoded from the Overpass API response.
public struct OSMTags: Decodable, Sendable {
    /// OSM amenity category value (e.g., "cafe", "restaurant", "pharmacy").
    public let amenity: String?
    /// Display name of the place as tagged in OSM.
    public let name: String?
    /// OSM `opening_hours` value (e.g., "Mo-Fr 08:00-20:00").
    public let openingHours: String?

    enum CodingKeys: String, CodingKey {
        case amenity
        case name
        case openingHours = "opening_hours"
    }
}
