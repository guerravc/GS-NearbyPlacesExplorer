//
//  DefaultAboutThePlaceServiceTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Guerra
//

import Testing
import Foundation
@testable import GS_NearbyPlacesExplorer

final class MockAPIRequestDispatcher: APIRequestDispatching, @unchecked Sendable {
    var performResult: Result<APIResponse, NetworkError>!
    var performedRoute: APIRouter?
    
    func perform(_ route: APIRouter) async -> Result<APIResponse, NetworkError> {
        performedRoute = route
        return performResult
    }
    
    func stream<T>(_ route: APIRouter) async -> Result<AsyncStream<T>, NetworkError> where T : Decodable {
        fatalError("Not implemented")
    }
}

@MainActor
struct DefaultAboutThePlaceServiceTests {

    @Test func test_fetchElementDetails_success_returnsElement() async throws {
        // Arrange
        let mockDispatcher = MockAPIRequestDispatcher()
        let jsonResponse = """
        {
            "elements": [
                {
                    "type": "node",
                    "id": 123,
                    "lat": 10.0,
                    "lon": 20.0,
                    "tags": {
                        "amenity": "cafe",
                        "name": "Test Cafe",
                        "opening_hours": "24/7"
                    }
                }
            ]
        }
        """
        
        let data = jsonResponse.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockDispatcher.performResult = .success(APIResponse(data: data, urlResponse: response))
        
        let apiClient = DefaultAPIClient(dispatcher: mockDispatcher)
        let service = DefaultAboutThePlaceService(apiClient: apiClient)
        
        // Act
        let result = try await service.fetchElementDetails(osmId: 123)
        
        // Assert
        #expect(result.id == 123)
        #expect(result.tags?.name == "Test Cafe")
        
        // Verify query formatting
        let route = try #require(mockDispatcher.performedRoute)
        let queryStr = try #require(String(data: route.body ?? Data(), encoding: .utf8))
        #expect(queryStr.contains("node(123);"))
        #expect(route.method == .post)
    }
}
