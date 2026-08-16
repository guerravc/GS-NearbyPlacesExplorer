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
        case .failure:
            state = .error("Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo.")
        }
    }
}
