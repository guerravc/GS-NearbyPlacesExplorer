// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  NearbyPlacesAPIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// API router for the NearbyPlaces module.
///
/// Builds Overpass QL queries sent as `application/x-www-form-urlencoded` POST bodies
/// to the Overpass API interpreter endpoint.
nonisolated public enum NearbyPlacesAPIRouter: APIRouter {
    /// Fetches nearby amenity nodes and ways within `radius` metres of the given coordinate.
    ///
    /// When `query` is provided the filter matches place names using a case-insensitive regex.
    /// When `query` is `nil`, all tagged amenities are returned.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the center coordinate.
    ///   - longitude: Longitude of the center coordinate.
    ///   - radius: Search radius in metres. Defaults to 1 000.
    ///   - query: Optional name filter.
    case fetchPlaces(latitude: Double, longitude: Double, radius: Int = 1000, query: String?)
    
    public var path: String {
        return ""
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var body: Data? {
        switch self {
        case let .fetchPlaces(lat, lon, radius, query):
            let filter = overpassFilter(for: query)
            let query = """
            [out:json][timeout:60];
            (
              node[\(filter)](around:\(radius),\(lat),\(lon));
              way[\(filter)](around:\(radius),\(lat),\(lon));
            );
            out center;
            """
            
            var components = URLComponents()
            components.queryItems = [URLQueryItem(name: "data", value: query)]
            return components.query?.data(using: .utf8)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }

    /// Builds the Overpass QL filter expression for the given optional search term.
    ///
    /// - Parameter query: Optional user search term.
    /// - Returns: A filter string such as `"amenity"` or `"name"~"term",i`.
    private func overpassFilter(for query: String?) -> String {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return "\"amenity\""
        }

        return "\"name\"~\"\(escapedForOverpassRegex(query))\",i"
    }

    /// Escapes special regex characters in the user's search term so they are treated as literals
    /// in the Overpass QL regex filter.
    ///
    /// - Parameter value: Raw search term entered by the user.
    /// - Returns: The escaped string safe for embedding in an Overpass QL regex.
    private func escapedForOverpassRegex(_ value: String) -> String {
        let specialCharacters = CharacterSet(charactersIn: #"\.^$|()[]{}*+?"#)
        return value.unicodeScalars.map { scalar in
            specialCharacters.contains(scalar) ? "\\\(String(scalar))" : String(scalar)
        }.joined()
    }
}
