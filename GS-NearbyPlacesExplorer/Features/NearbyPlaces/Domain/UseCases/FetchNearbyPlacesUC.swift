// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Input parameters for the ``FetchNearbyPlacesUC`` use case.
public struct FetchNearbyPlacesInput: Sendable {
    /// Latitude of the user's current position.
    public let latitude: Double
    /// Longitude of the user's current position.
    public let longitude: Double
    /// Optional search term to filter results by name. `nil` returns all nearby amenities.
    public let query: String?
}

/// Async use case that fetches nearby points of interest for a given location.
///
/// Accepts a ``FetchNearbyPlacesInput`` and returns an array of ``NearbyPlacesEntity``.
public protocol FetchNearbyPlacesUC: AsyncOperationUseCase
where Input == FetchNearbyPlacesInput, Output == [NearbyPlacesEntity] {}

/// Default implementation of ``FetchNearbyPlacesUC``.
///
/// Delegates to ``NearbyPlacesGateway`` to retrieve the list of places.
public final class FetchNearbyPlacesUCImpl: FetchNearbyPlacesUC {

    /// Gateway used to retrieve nearby places from the data layer.
    @Inject private var gateway: NearbyPlacesGateway

    /// Initializes a new instance of `FetchNearbyPlacesUCImpl`.
    public init() {}

    /// Executes the fetch using the provided coordinates and optional query.
    /// - Parameter input: Location and optional search term.
    /// - Returns: A result containing the matched entities or an error.
    public func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
        return await gateway.fetchNearbyPlaces(
            latitude: input.latitude,
            longitude: input.longitude,
            query: input.query
        )
    }
}
