import Foundation

public final class NearbyPlacesRepository: NearbyPlacesGateway {
    @Inject private var service: NearbyPlacesRemoteDataSource
    
    public init() {}
    
    public func fetchNearbyPlaces(latitude: Double, longitude: Double, query: String?) async -> Result<[NearbyPlacesEntity], Error> {
        do {
            let dtos = try await service.search(latitude: latitude, longitude: longitude, query: query)
            return .success(dtos.map { $0.toEntity() })
        } catch {
            return .failure(error)
        }
    }
}
