//
//  NearbyPlacesAPIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

nonisolated public enum NearbyPlacesAPIRouter: APIRouter {
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
            [out:json][timeout:25];
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

    private func overpassFilter(for query: String?) -> String {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return "\"amenity\""
        }

        return "\"name\"~\"\(escapedForOverpassRegex(query))\",i"
    }

    private func escapedForOverpassRegex(_ value: String) -> String {
        let specialCharacters = CharacterSet(charactersIn: #"\.^$|()[]{}*+?"#)
        return value.unicodeScalars.map { scalar in
            specialCharacters.contains(scalar) ? "\\\(String(scalar))" : String(scalar)
        }.joined()
    }
}
