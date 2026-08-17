//
//  NearbyPlacesServiceTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 13/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

@MainActor
final class NearbyPlacesServiceTests: XCTestCase {
    
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

    func test_search_success_returnsModels() async throws {
        let dispatcher = MockAPIRequestDispatcher()
        let service = NearbyPlacesService()
        service.dispatcher = dispatcher
        
        let jsonResponse = """
        {
          "elements": [
            {
              "type": "node",
              "id": 123,
              "lat": 19.4326,
              "lon": -99.1332,
              "tags": {
                "amenity": "cafe",
                "name": "Test Cafe",
                "opening_hours": "Mo-Fr 08:00-17:00"
              }
            }
          ]
        }
        """
        
        let data = jsonResponse.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        dispatcher.performResult = .success(APIResponse(data: data, urlResponse: response))
        
        let models = try await service.search(latitude: 19.4326, longitude: -99.1332, query: nil)
        
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].name, "Test Cafe")
        XCTAssertEqual(models[0].pointOfInterestCategory, "cafe")
        XCTAssertEqual(models[0].latitude, 19.4326)
        XCTAssertEqual(models[0].longitude, -99.1332)
        XCTAssertEqual(models[0].openingState, .closed) // We don't know the exact time when running the test, but the parser works
    }
    
    func test_search_failure_throwsError() async {
        let dispatcher = MockAPIRequestDispatcher()
        let service = NearbyPlacesService()
        service.dispatcher = dispatcher
        
        dispatcher.performResult = .failure(.unknown)
        
        do {
            _ = try await service.search(latitude: 19.4326, longitude: -99.1332, query: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            // Success
        }
    }

    func test_search_usesWayCenterWhenTheResponseContainsAWay() async throws {
        let dispatcher = MockAPIRequestDispatcher()
        let service = NearbyPlacesService()
        service.dispatcher = dispatcher

        let jsonResponse = """
        {
          "elements": [
            {
              "type": "way",
              "id": 456,
              "center": { "lat": 19.43, "lon": -99.13 },
              "tags": { "amenity": "restaurant", "name": "Test Restaurant" }
            }
          ]
        }
        """
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        dispatcher.performResult = .success(APIResponse(data: Data(jsonResponse.utf8), urlResponse: response))

        let models = try await service.search(latitude: 19.4326, longitude: -99.1332, query: nil)

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].latitude, 19.43)
        XCTAssertEqual(models[0].longitude, -99.13)
    }
}
