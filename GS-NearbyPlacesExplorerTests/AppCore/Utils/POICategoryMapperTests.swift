import XCTest
@testable import GS_NearbyPlacesExplorer

final class POICategoryMapperTests: XCTestCase {
    func test_mapCategory_returnsExpectedSFSymbol() {
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryRestaurant"), "fork.knife")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryCafe"), "cup.and.saucer.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryBakery"), "takeoutbag.and.cup.and.straw.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryHospital"), "cross.case.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryPharmacy"), "pills.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryBank"), "building.columns.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryATM"), "atm")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryStore"), "bag.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategorySupermarket"), "cart.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryGasStation"), "fuelpump.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryEVCharger"), "ev.charger.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryParking"), "parkingsign.circle.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryHotel"), "bed.double.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryPark"), "tree.fill")
        XCTAssertEqual(POICategoryMapper.map(category: "MKPOICategoryFitnessCenter"), "dumbbell.fill")
    }
    
    func test_mapCategory_withUnknownCategory_returnsFallback() {
        XCTAssertEqual(POICategoryMapper.map(category: "SomeUnknownCategory"), "mappin.and.ellipse")
    }
    
    func test_mapCategory_withEmptyCategory_returnsFallback() {
        XCTAssertEqual(POICategoryMapper.map(category: ""), "mappin.and.ellipse")
    }
}
