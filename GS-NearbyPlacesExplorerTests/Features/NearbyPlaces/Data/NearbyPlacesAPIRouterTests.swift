// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  NearbyPlacesAPIRouterTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 13/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

final class NearbyPlacesAPIRouterTests: XCTestCase {

    func test_fetchPlaces_properties() {
        let lat = 19.4326
        let lon = -99.1332
        let radius = 1000
        let router = NearbyPlacesAPIRouter.fetchPlaces(
            latitude: lat,
            longitude: lon,
            radius: radius,
            query: nil
        )
        
        XCTAssertEqual(router.method, .post)
        XCTAssertEqual(router.headers?["Content-Type"], "application/x-www-form-urlencoded")

        let request = try? APIRequestBuilder.build(for: router).get()
        XCTAssertEqual(request?.url?.absoluteString, "https://overpass-api.de/api/interpreter")
        
        let bodyString = String(data: router.body ?? Data(), encoding: .utf8) ?? ""
        XCTAssertTrue(bodyString.contains("amenity"))
        XCTAssertTrue(bodyString.starts(with: "data="))
    }

    func test_fetchPlaces_withQuery_filtersByNameWithoutAmenityRestriction() {
        let router = NearbyPlacesAPIRouter.fetchPlaces(
            latitude: 19.4326,
            longitude: -99.1332,
            radius: 1000,
            query: "Pizza & Pasta"
        )

        let bodyString = String(data: router.body ?? Data(), encoding: .utf8) ?? ""
        let decodedBody = bodyString.removingPercentEncoding ?? bodyString

        XCTAssertTrue(decodedBody.contains("[\"name\"~\"Pizza & Pasta\",i]"))
        XCTAssertFalse(decodedBody.contains("[\"amenity\"]"))
        XCTAssertTrue(decodedBody.contains("way"))
    }
}
