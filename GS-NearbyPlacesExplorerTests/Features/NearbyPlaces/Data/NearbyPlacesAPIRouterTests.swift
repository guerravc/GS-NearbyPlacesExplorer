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
        let router = NearbyPlacesAPIRouter.fetchPlaces(latitude: lat, longitude: lon, radius: radius)
        
        XCTAssertEqual(router.path, "")
        XCTAssertEqual(router.method, .post)
        XCTAssertEqual(router.headers?["Content-Type"], "application/x-www-form-urlencoded")
        
        let bodyString = String(data: router.body ?? Data(), encoding: .utf8) ?? ""
        XCTAssertTrue(bodyString.contains("amenity"))
        XCTAssertTrue(bodyString.starts(with: "data="))
    }
}