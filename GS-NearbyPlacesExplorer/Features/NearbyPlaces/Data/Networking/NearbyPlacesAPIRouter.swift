//
//  NearbyPlacesAPIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

public enum NearbyPlacesAPIRouter: APIRouter {
    case fetchPlaces(latitude: Double, longitude: Double, radius: Int = 1000)
    
    public var path: String {
        return ""
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var body: Data? {
        switch self {
        case let .fetchPlaces(lat, lon, radius):
            let query = """
            [out:json][timeout:25];
            (
              node["amenity"](around:\(radius),\(lat),\(lon));
            );
            out body;
            >;
            out skel qt;
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