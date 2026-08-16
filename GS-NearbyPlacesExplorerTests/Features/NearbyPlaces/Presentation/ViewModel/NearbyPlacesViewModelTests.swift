import XCTest
@testable import GS_NearbyPlacesExplorer

@MainActor
final class NearbyPlacesViewModelTests: XCTestCase {
    
    func test_search_withEmptyResults_showsEmptyState() async {
        let mockUC = MockFetchNearbyPlacesUC()
        mockUC.mockResult = []
        
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
        await sut.search(latitude: 0, longitude: 0, query: "Café")
        
        let expectedState = NearbyPlacesViewModel.ViewState.empty("No encontramos resultados para 'Café'. Intenta con otra búsqueda.")
        let actualState = sut.state
        XCTAssertEqual(actualState, expectedState)
    }
    
    func test_search_withEmptyResultsAndNoQuery_showsEmptyStateForLocation() async {
        let mockUC = MockFetchNearbyPlacesUC()
        mockUC.mockResult = []
        
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
        await sut.search(latitude: 0, longitude: 0, query: "")
        
        let expectedState = NearbyPlacesViewModel.ViewState.empty("No encontramos resultados para 'tu ubicación'. Intenta con otra búsqueda.")
        let actualState = sut.state
        XCTAssertEqual(actualState, expectedState)
    }
    
    func test_search_withError_showsNetworkErrorState() async {
        let mockUC = MockFetchNearbyPlacesUC()
        mockUC.mockError = NSError(domain: "Test", code: -1, userInfo: nil)
        
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
        await sut.search(latitude: 0, longitude: 0, query: "Café")
        
        let expectedState = NearbyPlacesViewModel.ViewState.error("Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo.")
        let actualState = sut.state
        XCTAssertEqual(actualState, expectedState)
    }
    
    func test_search_withSuccess_showsLoadedState() async {
        let mockUC = MockFetchNearbyPlacesUC()
        let entity = NearbyPlacesEntity(id: "1", name: "Test Place", coordinate: (latitude: 10, longitude: 10), category: "MKPOICategoryRestaurant", address: "123 Main St")
        mockUC.mockResult = [entity]
        
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
        await sut.search(latitude: 0, longitude: 0, query: "Café")
        
        let state = sut.state
        if case .loaded(let models) = state {
            XCTAssertEqual(models.count, 1)
            XCTAssertEqual(models.first?.name, "Test Place")
        } else {
            XCTFail("Expected loaded state")
        }
    }
}

fileprivate class MockFetchNearbyPlacesUC: FetchNearbyPlacesUC, @unchecked Sendable {
    var mockResult: [NearbyPlacesEntity] = []
    var mockError: Error?
    
    func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
        if let error = mockError {
            return .failure(error)
        }
        return .success(mockResult)
    }
}
