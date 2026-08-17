import Observation
import Foundation

@MainActor
public protocol NearbyPlacesViewModelProtocol: AnyObject {
    var title: String { get }
    var state: NearbyPlacesViewModel.ViewState { get }
    
    func onAppear() async
    func reload() async
    
    func search(latitude: Double, longitude: Double, query: String?) async
}

@MainActor
@Observable
public final class NearbyPlacesViewModel: NearbyPlacesViewModelProtocol {

    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded([NearbyPlacesEntity])
        case error(String)
        case empty(String)
    }

    public var title: String = "Lugares"
    public var state: ViewState = .idle
    public var query: String = ""
    
    @ObservationIgnored
    @Inject private var fetchNearbyPlacesUC: any FetchNearbyPlacesUC

    public init() {}
    
    public init(fetchNearbyPlacesUC: any FetchNearbyPlacesUC) {
        self.fetchNearbyPlacesUC = fetchNearbyPlacesUC
    }
    
    public func onAppear() async {}
    
    public func reload() async {}

    public func search(latitude: Double, longitude: Double, query: String?) async {
        state = .loading
        
        let input = FetchNearbyPlacesInput(latitude: latitude, longitude: longitude, query: query)
        let result = await fetchNearbyPlacesUC.execute(input)
        
        switch result {
        case .success(let entities):
            if entities.isEmpty {
                let term = (query?.isEmpty == false) ? query! : "tu ubicación"
                state = .empty("No encontramos resultados para '\(term)'. Intenta con otra búsqueda.")
            } else {
                state = .loaded(entities)
            }
        case .failure(let error):
            state = .error(searchErrorMessage(for: error))
        }
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
