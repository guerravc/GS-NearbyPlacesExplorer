import XCTest
@testable import GS_NearbyPlacesExplorer

final class POICategoryMapperTests: XCTestCase {
    func test_mapCategory_withUnknownCategory_returnsFallback() {
        XCTAssertEqual(POICategoryMapper.map(category: "SomeUnknownCategory"), "mappin.and.ellipse")
    }

    func test_mapCategory_withOSMAmenities_returnsExpectedSFSymbols() {
        XCTAssertEqual(POICategoryMapper.map(category: "restaurant"), "fork.knife")
        XCTAssertEqual(POICategoryMapper.map(category: "fast_food"), "fork.knife")
        XCTAssertEqual(POICategoryMapper.map(category: "cafe"), "cup.and.saucer.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "hospital"), "cross.case.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "pharmacy"), "pills.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "bank"), "building.columns.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "fuel"), "fuelpump.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "parking"), "parkingsign.circle.fill")
    }
    
    func test_mapCategory_withEmptyCategory_returnsFallback() {
        XCTAssertEqual(POICategoryMapper.map(category: ""), "mappin.and.ellipse")
    }
}
