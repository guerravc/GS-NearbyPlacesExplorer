// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Default implementation of ``NearbyPlacesGateway``, backed by a remote data source.
///
/// Fetches places from the network and maps the resulting DTOs to domain entities
/// before returning them to the domain layer.
public final class NearbyPlacesRepository: NearbyPlacesGateway {

    /// Remote data source used to query the Overpass API.
    @Inject private var service: NearbyPlacesRemoteDataSource

    /// Initializes a new instance of `NearbyPlacesRepository`.
    public init() {}

    /// Fetches nearby places from the remote data source and maps them to domain entities.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the center coordinate.
    ///   - longitude: Longitude of the center coordinate.
    ///   - query: Optional text filter applied to place names.
    /// - Returns: A result containing an array of ``NearbyPlacesEntity`` or an error.
    public func fetchNearbyPlaces(
        latitude: Double,
        longitude: Double,
        query: String?
    ) async -> Result<[NearbyPlacesEntity], Error> {
        do {
            let dtos = try await service.search(latitude: latitude, longitude: longitude, query: query)
            return .success(dtos.map { $0.toEntity() })
        } catch {
            return .failure(error)
        }
    }
}
