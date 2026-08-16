import Foundation

public struct FetchNearbyPlacesInput: Sendable {
    public let latitude: Double
    public let longitude: Double
    public let query: String?
}

public protocol FetchNearbyPlacesUC: AsyncOperationUseCase where Input == FetchNearbyPlacesInput, Output == [NearbyPlacesEntity] {}

public final class FetchNearbyPlacesUCImpl: FetchNearbyPlacesUC {
    @Inject private var gateway: NearbyPlacesGateway
    
    public init() {}
    
    public func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
        return await gateway.fetchNearbyPlaces(latitude: input.latitude, longitude: input.longitude, query: input.query)
    }
}
