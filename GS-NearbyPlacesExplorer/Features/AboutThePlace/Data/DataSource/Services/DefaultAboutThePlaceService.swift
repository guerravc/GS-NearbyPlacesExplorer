//
//  DefaultAboutThePlaceService.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation



public struct DefaultAboutThePlaceService: AboutThePlaceRemoteDataSource {
    private let apiClient: APIClient
    
    public init(apiClient: APIClient = DefaultAPIClient(dispatcher: APIRequestDispatcher())) {
        self.apiClient = apiClient
    }
    
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
