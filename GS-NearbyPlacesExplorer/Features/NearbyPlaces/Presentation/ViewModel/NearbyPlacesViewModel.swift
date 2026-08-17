// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Observation
import Foundation

/// Contract for the NearbyPlaces view model, enabling easy mocking in previews and tests.
@MainActor
public protocol NearbyPlacesViewModelProtocol: AnyObject {
    /// Localized navigation title displayed by the view.
    var title: String { get }
    /// Current loading/content state of the view.
    var state: NearbyPlacesViewModel.ViewState { get }
    /// Search query text bound to the search field.
    var query: String { get set }
    /// Whether an error alert should be presented.
    var showError: Bool { get set }
    /// Localized error message shown in the alert.
    var errorMessage: String? { get }

    /// Called once when the view appears for the first time.
    func onAppear() async
    /// Triggers a manual reload of the current result set.
    func reload() async
    /// Schedules a debounced search for the current query and location.
    func scheduleSearch(latitude: Double, longitude: Double)
    /// Submits an immediate search bypassing the debounce delay.
    func submitSearch(latitude: Double, longitude: Double)
    /// Retries the most recent search using the last known input.
    func retryLastSearch()
}

/// View model for the NearbyPlaces screen.
///
/// Manages search state, debouncing, cancellation of in-flight requests,
/// and transforms domain errors into user-facing messages.
/// Conforms to ``NearbyPlacesViewModelProtocol`` to facilitate testing and previews.
@MainActor
@Observable
public final class NearbyPlacesViewModel: NearbyPlacesViewModelProtocol {

    /// Represents the possible content states of the NearbyPlaces screen.
    public enum ViewState: Equatable {
        /// No search has been performed yet.
        case idle
        /// Places were found; the associated value holds the list.
        case loaded([NearbyPlacesEntity])
        /// The search returned no results; the associated value is a user-facing message.
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

    /// Schedules a debounced search for the current query at the given location.
    ///
    /// Searches with a query shorter than 3 characters are ignored.
    /// If a query is active, the search is delayed by `debounceDuration`.
    /// - Parameters:
    ///   - latitude: Current latitude.
    ///   - longitude: Current longitude.
    public func scheduleSearch(latitude: Double, longitude: Double) {
        let input = searchInput(latitude: latitude, longitude: longitude)
        invalidatePendingSearch()

        guard input.query.map({ $0.count >= 3 }) ?? true else { return }

        startSearch(input: input, delayed: input.query != nil)
    }

    /// Submits an immediate search bypassing the debounce delay.
    ///
    /// Requires the query to be at least 3 characters; otherwise no-ops.
    /// - Parameters:
    ///   - latitude: Current latitude.
    ///   - longitude: Current longitude.
    public func submitSearch(latitude: Double, longitude: Double) {
        let input = searchInput(latitude: latitude, longitude: longitude)
        invalidatePendingSearch()

        guard input.query?.count ?? 0 >= 3 else { return }

        startSearch(input: input, delayed: false)
    }

    /// Retries the last search that was performed, using the same input.
    /// No-ops if there is no previous search to retry.
    public func retryLastSearch() {
        guard let lastSearchInput else { return }

        invalidatePendingSearch()
        startSearch(input: lastSearchInput, delayed: false)
    }

    /// Executes a search directly without debouncing. Used for testing.
    /// - Parameters:
    ///   - latitude: Latitude of the search origin.
    ///   - longitude: Longitude of the search origin.
    ///   - query: Optional search term.
    public func search(latitude: Double, longitude: Double, query: String?) async {
        let input = FetchNearbyPlacesInput(latitude: latitude, longitude: longitude, query: normalizedQuery(query))
        invalidatePendingSearch()
        lastSearchInput = input
        let requestID = currentRequestID
        await executeSearch(input: input, requestID: requestID)
    }

    /// Starts a search task, optionally waiting for the debounce delay first.
    /// - Parameters:
    ///   - input: Search parameters to use.
    ///   - delayed: Whether to wait for `debounceDuration` before dispatching.
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

    /// Dispatches the use case and updates view state, discarding stale responses.
    ///
    /// Stale detection uses `requestID`: if it no longer matches `currentRequestID`
    /// a newer search has started and this result is silently discarded.
    /// - Parameters:
    ///   - input: Search parameters.
    ///   - requestID: Unique identifier for this particular request.
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

    /// Builds a ``FetchNearbyPlacesInput`` from the given coordinates and the current query.
    /// - Returns: A fully configured input struct.
    private func searchInput(latitude: Double, longitude: Double) -> FetchNearbyPlacesInput {
        FetchNearbyPlacesInput(
            latitude: latitude,
            longitude: longitude,
            query: normalizedQuery(query)
        )
    }

    /// Trims whitespace from the query and returns `nil` if it is empty.
    /// - Parameter query: Raw query string.
    /// - Returns: Trimmed non-empty string, or `nil`.
    private func normalizedQuery(_ query: String?) -> String? {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return nil
        }
        return query
    }

    /// Increments `currentRequestID` and cancels any pending search task,
    /// effectively discarding in-flight results from the previous request.
    private func invalidatePendingSearch() {
        currentRequestID = UUID()
        $searchTask.cancel()
    }

    /// Returns `true` when `error` represents a request cancellation.
    /// - Parameter error: The error to inspect.
    private func isCancellation(_ error: Error) -> Bool {
        guard let networkError = error as? NetworkError else { return false }
        if case .cancelled = networkError {
            return true
        }
        return false
    }

    /// Converts a ``NetworkError`` into a localized user-facing message.
    /// - Parameter error: The networking error to describe.
    /// - Returns: A Spanish-language string suitable for display in an alert.
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
