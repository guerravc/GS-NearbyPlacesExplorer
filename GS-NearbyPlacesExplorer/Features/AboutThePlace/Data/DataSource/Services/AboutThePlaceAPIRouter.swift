// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceAPIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// API router for the AboutThePlace module.
///
/// Builds Overpass QL queries sent as `application/x-www-form-urlencoded` POST bodies
/// to the Overpass API interpreter endpoint.
public enum AboutThePlaceAPIRouter: APIRouter, Sendable {
    /// Fetches the OSM node matching the given identifier, including its center coordinate and tags.
    /// - Parameter osmId: The unique OSM element ID.
    case fetchElementDetails(osmId: Int)
    
    public var path: String {
        return ""
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var body: Data? {
        switch self {
        case .fetchElementDetails(let osmId):
            let query = """
            [out:json][timeout:25];
            node(\(osmId));
            out center tags;
            """
            var components = URLComponents()
            components.queryItems = [URLQueryItem(name: "data", value: query)]
            return components.query?.data(using: .utf8)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}
