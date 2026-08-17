// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  DefaultAboutThePlaceService.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation



/// Remote data source for the AboutThePlace module.
///
/// Issues an Overpass API request using ``AboutThePlaceAPIRouter`` and returns
/// the first ``OSMElement`` in the response.
public struct DefaultAboutThePlaceService: AboutThePlaceRemoteDataSource {
    private let apiClient: APIClient
    
    public init(apiClient: APIClient = DefaultAPIClient(dispatcher: APIRequestDispatcher())) {
        self.apiClient = apiClient
    }
    
    /// Fetches the OSM element matching the given identifier from the Overpass API.
    ///
    /// - Parameter osmId: Unique OSM element ID to look up.
    /// - Returns: The first ``OSMElement`` returned by the API.
    /// - Throws: `NSError` (domain: `"AboutThePlaceService"`, code: 404) when no element is found,
    ///   or a ``NetworkError`` when the HTTP request fails.
    public func fetchElementDetails(osmId: Int) async throws -> OSMElement {
        let router = AboutThePlaceAPIRouter.fetchElementDetails(osmId: osmId)
        let result: Result<OverpassResponse, NetworkError> = await apiClient.request(router)
        
        switch result {
        case .success(let response):
            guard let element = response.elements.first else {
                throw NSError(domain: "AboutThePlaceService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Element not found"])
            }
            return element
        case .failure(let error):
            throw error
        }
    }
}
