import Observation
import Foundation

@MainActor
public protocol NearbyPlacesViewModelProtocol: AnyObject {
    var title: String { get }
    var state: NearbyPlacesViewModel.ViewState { get }
    var query: String { get set }
    var showError: Bool { get set }
    var errorMessage: String? { get }

    func onAppear() async
    func reload() async
    func scheduleSearch(latitude: Double, longitude: Double)
    func submitSearch(latitude: Double, longitude: Double)
    func retryLastSearch()
}

@MainActor
@Observable
public final class NearbyPlacesViewModel: NearbyPlacesViewModelProtocol {

    public enum ViewState: Equatable {
        case idle
        case loaded([NearbyPlacesEntity])
        case empty(String)
    }

    public var title: String = "Lugares"
    public var state: ViewState = .idle
    public var query: String = ""
    public var showError = false
    public internal(set) var errorMessage: String?

    @ObservationIgnored
    @Inject private var fetchNearbyPlacesUC: any FetchNearbyPlacesUC

    @ObservationIgnored
    @CancellableTask<Void, Never> private var searchTask

    @ObservationIgnored
    private let debounceDuration: Duration

    @ObservationIgnored
    private var currentRequestID = UUID()

    @ObservationIgnored
    private var lastSearchInput: FetchNearbyPlacesInput?

    public init(debounceDuration: Duration = .milliseconds(350)) {
        self.debounceDuration = debounceDuration
    }

    public init(
        fetchNearbyPlacesUC: any FetchNearbyPlacesUC,
        debounceDuration: Duration = .milliseconds(350)
    ) {
        self.debounceDuration = debounceDuration
        self.fetchNearbyPlacesUC = fetchNearbyPlacesUC
    }

    public func onAppear() async {}

    public func reload() async {}

    public func scheduleSearch(latitude: Double, longitude: Double) {
        let input = searchInput(latitude: latitude, longitude: longitude)
        invalidatePendingSearch()

        guard input.query.map({ $0.count >= 3 }) ?? true else { return }

        startSearch(input: input, delayed: input.query != nil)
    }

    public func submitSearch(latitude: Double, longitude: Double) {
        let input = searchInput(latitude: latitude, longitude: longitude)
        invalidatePendingSearch()

        guard input.query?.count ?? 0 >= 3 else { return }

        startSearch(input: input, delayed: false)
    }

    public func retryLastSearch() {
        guard let lastSearchInput else { return }

        invalidatePendingSearch()
        startSearch(input: lastSearchInput, delayed: false)
    }

    public func search(latitude: Double, longitude: Double, query: String?) async {
        let input = FetchNearbyPlacesInput(latitude: latitude, longitude: longitude, query: normalizedQuery(query))
        invalidatePendingSearch()
        lastSearchInput = input
        let requestID = currentRequestID
        await executeSearch(input: input, requestID: requestID)
    }

    private func startSearch(input: FetchNearbyPlacesInput, delayed: Bool) {
        lastSearchInput = input
        let requestID = currentRequestID

        searchTask = Task { [weak self] in
            guard let self else { return }

            if delayed {
                do {
                    try await Task.sleep(for: self.debounceDuration)
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            await self.executeSearch(input: input, requestID: requestID)
        }
    }

    private func executeSearch(input: FetchNearbyPlacesInput, requestID: UUID) async {
        let result = await fetchNearbyPlacesUC.execute(input)

        guard !Task.isCancelled, requestID == currentRequestID else { return }

        switch result {
        case .success(let entities):
            if entities.isEmpty {
                let term = input.query ?? "tu ubicación"
                state = .empty("No encontramos resultados para '\(term)'. Intenta con otra búsqueda.")
            } else {
                state = .loaded(entities)
            }
        case .failure(let error):
            guard !isCancellation(error) else { return }
            errorMessage = searchErrorMessage(for: error)
            showError = true
        }
    }

    private func searchInput(latitude: Double, longitude: Double) -> FetchNearbyPlacesInput {
        FetchNearbyPlacesInput(
            latitude: latitude,
            longitude: longitude,
            query: normalizedQuery(query)
        )
    }

    private func normalizedQuery(_ query: String?) -> String? {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return nil
        }
        return query
    }

    private func invalidatePendingSearch() {
        currentRequestID = UUID()
        $searchTask.cancel()
    }

    private func isCancellation(_ error: Error) -> Bool {
        guard let networkError = error as? NetworkError else { return false }
        if case .cancelled = networkError {
            return true
        }
        return false
    }

    private func searchErrorMessage(for error: Error) -> String {
        guard let networkError = error as? NetworkError else {
            return "Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo."
        }

        switch networkError {
        case .transportError(let error as URLError):
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost,
                .dnsLookupFailed:
                return "No fue posible conectarse al servicio de lugares. Revisa tu conexión e intenta de nuevo."
            case .timedOut:
                return "El servicio de lugares tardó demasiado en responder. Intenta de nuevo."
            default:
                return "No fue posible completar la solicitud al servicio de lugares."
            }
        case .transportError:
            return "No fue posible completar la solicitud al servicio de lugares."
        case .serverError(let statusCode, _):
            return "El servicio de lugares respondió con el error \(statusCode.rawValue)."
        case .unacceptableStatusCode(let statusCode, _):
            return "El servicio de lugares respondió con el error \(statusCode)."
        case .decodingError:
            return "El servicio de lugares devolvió una respuesta que no pudimos procesar."
        case .invalidURL:
            return "La configuración del servicio de lugares no es válida."
        case .noData:
            return "El servicio de lugares no devolvió datos."
        case .cancelled:
            return "La búsqueda fue cancelada."
        case .unknown:
            return "Ocurrió un error inesperado al buscar lugares."
        }
    }
}
