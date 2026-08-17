//
//  AboutThePlaceAPIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public enum AboutThePlaceAPIRouter: APIRouter, Sendable {
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
