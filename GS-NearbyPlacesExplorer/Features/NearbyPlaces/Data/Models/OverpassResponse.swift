//
//  OverpassResponse.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

public struct OverpassResponse: Decodable, Sendable {
    public let elements: [OSMElement]
}

public struct OSMElement: Decodable, Sendable {
    public let type: String
    public let id: Int
    public let lat: Double?
    public let lon: Double?
    public let center: OSMCenter?
    public let tags: OSMTags?
}

public struct OSMCenter: Decodable, Sendable {
    public let lat: Double
    public let lon: Double
}

public struct OSMTags: Decodable, Sendable {
    public let amenity: String?
    public let name: String?
    public let openingHours: String?
    
    enum CodingKeys: String, CodingKey {
        case amenity
        case name
        case openingHours = "opening_hours"
    }
}
