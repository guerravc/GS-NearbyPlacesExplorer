// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import XCTest
@testable import GS_NearbyPlacesExplorer

@MainActor
final class NearbyPlacesViewModelTests: XCTestCase {

    func test_search_withEmptyResults_showsEmptyState() async {
        let mockUC = MockFetchNearbyPlacesUC()
        mockUC.mockResult = []
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)

        await sut.search(latitude: 0, longitude: 0, query: "Café")

        XCTAssertEqual(
            sut.state,
            .empty("No encontramos resultados para 'Café'. Intenta con otra búsqueda.")
        )
    }

    func test_search_withSuccess_showsLoadedState() async {
        let mockUC = MockFetchNearbyPlacesUC()
        let entity = NearbyPlacesEntity(
            id: "1", name: "Test Place", coordinate: (latitude: 10, longitude: 10),
            category: "restaurant", address: "123 Main St"
        )
        mockUC.mockResult = [entity]
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)

        await sut.search(latitude: 0, longitude: 0, query: "Café")

        XCTAssertEqual(sut.state, .loaded([entity]))
    }

    func test_search_withError_preservesResultsAndPresentsAlert() async {
        let mockUC = MockFetchNearbyPlacesUC()
        let entity = NearbyPlacesEntity(
            id: "1", name: "Test Place", coordinate: (latitude: 10, longitude: 10),
            category: "restaurant", address: "123 Main St"
        )
        mockUC.mockResult = [entity]
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
        await sut.search(latitude: 0, longitude: 0, query: "Café")

        mockUC.mockError = NetworkError.serverError(statusCode: .notFound, data: nil)
        await sut.search(latitude: 0, longitude: 0, query: "Restaurante")

        XCTAssertEqual(sut.state, .loaded([entity]))
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "El servicio de lugares respondió con el error 404.")
    }

    func test_scheduleSearch_withFewerThanThreeCharacters_doesNotCallUseCase() async throws {
        let mockUC = MockFetchNearbyPlacesUC()
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC, debounceDuration: .zero)
        sut.query = "ca"

        sut.scheduleSearch(latitude: 0, longitude: 0)
        try await Task.sleep(for: .milliseconds(20))

        XCTAssertEqual(mockUC.inputs.count, 0)
    }

    func test_scheduleSearch_withThreeCharacters_callsUseCaseAfterDebounce() async throws {
        let mockUC = MockFetchNearbyPlacesUC()
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC, debounceDuration: .milliseconds(20))
        sut.query = "caf"

        sut.scheduleSearch(latitude: 1, longitude: 2)
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(mockUC.inputs.count, 1)
        XCTAssertEqual(mockUC.inputs.first?.latitude, 1)
        XCTAssertEqual(mockUC.inputs.first?.longitude, 2)
        XCTAssertEqual(mockUC.inputs.first?.query, "caf")
    }

    func test_scheduleSearch_withEmptyQuery_callsDefaultImmediately() async {
        let mockUC = MockFetchNearbyPlacesUC()
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC, debounceDuration: .seconds(1))

        sut.scheduleSearch(latitude: 1, longitude: 2)
        await Task.yield()

        XCTAssertEqual(mockUC.inputs.count, 1)
        XCTAssertEqual(mockUC.inputs.first?.query, nil)
    }

    func test_submitSearch_bypassesDebounceForValidQuery() async {
        let mockUC = MockFetchNearbyPlacesUC()
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC, debounceDuration: .seconds(1))
        sut.query = "cafe"

        sut.submitSearch(latitude: 1, longitude: 2)
        await Task.yield()

        XCTAssertEqual(mockUC.inputs.count, 1)
        XCTAssertEqual(mockUC.inputs.first?.query, "cafe")
    }

    func test_newerSearch_discardsLateResultFromOlderSearch() async throws {
        let mockUC = ControlledFetchNearbyPlacesUC()
        let sut = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC, debounceDuration: .zero)

        sut.query = "cafe"
        sut.scheduleSearch(latitude: 0, longitude: 0)
        try await waitUntil { mockUC.inputs.count == 1 }

        sut.query = "pizza"
        sut.scheduleSearch(latitude: 0, longitude: 0)
        try await waitUntil { mockUC.inputs.count == 2 }

        mockUC.resume(at: 0, with: .success([NearbyPlacesEntity(
            id: "old", name: "Old", coordinate: (0, 0), category: "cafe", address: ""
        )]))
        mockUC.resume(at: 1, with: .success([NearbyPlacesEntity(
            id: "new", name: "New", coordinate: (0, 0), category: "restaurant", address: ""
        )]))

        try await waitUntil {
            if case .loaded(let places) = sut.state {
                return places.first?.id == "new"
            }
            return false
        }

        XCTAssertEqual(sut.state, .loaded([NearbyPlacesEntity(
            id: "new", name: "New", coordinate: (0, 0), category: "restaurant", address: ""
        )]))
    }

    private func waitUntil(
        timeout: Duration = .seconds(1),
        condition: @escaping @MainActor () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout

        while !condition() {
            guard clock.now < deadline else {
                XCTFail("Timed out waiting for condition")
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
    }
}

private final class MockFetchNearbyPlacesUC: FetchNearbyPlacesUC, @unchecked Sendable {
    var mockResult: [NearbyPlacesEntity] = []
    var mockError: Error?
    var inputs: [FetchNearbyPlacesInput] = []

    func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
        inputs.append(input)
        if let mockError {
            return .failure(mockError)
        }
        return .success(mockResult)
    }
}

private final class ControlledFetchNearbyPlacesUC: FetchNearbyPlacesUC, @unchecked Sendable {
    var inputs: [FetchNearbyPlacesInput] = []
    private var continuations: [CheckedContinuation<Result<[NearbyPlacesEntity], Error>, Never>] = []

    func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
        inputs.append(input)
        return await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func resume(at index: Int, with result: Result<[NearbyPlacesEntity], Error>) {
        continuations[index].resume(returning: result)
    }
}
