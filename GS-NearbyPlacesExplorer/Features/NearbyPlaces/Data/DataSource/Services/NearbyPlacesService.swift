// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Overpass API–backed implementation of the remote data source for the NearbyPlaces module.
///
/// Constructs and dispatches Overpass QL queries via ``NearbyPlacesAPIRouter``,
/// then parses the ``OverpassResponse`` into a list of ``NearbyPlacesModel`` DTOs.
public final class NearbyPlacesService: NearbyPlacesRemoteDataSource, @unchecked Sendable {

    /// Dispatcher responsible for executing HTTP requests.
    @Inject var dispatcher: APIRequestDispatching

    /// Initializes a new instance of `NearbyPlacesService`.
    public init() {}

    /// Searches for nearby amenities around the given coordinates using the Overpass API.
    ///
    /// A radius of 1 000 m is used for all queries. When `query` is provided,
    /// results are filtered by place name using a case-insensitive regex.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the center coordinate.
    ///   - longitude: Longitude of the center coordinate.
    ///   - query: Optional text filter applied to place names.
    /// - Returns: An array of ``NearbyPlacesModel`` DTOs ready for mapping to domain entities.
    /// - Throws: ``NetworkError`` if the request or decoding fails.
    public func search(latitude: Double, longitude: Double, query: String?) async throws -> [NearbyPlacesModel] {
        let route = NearbyPlacesAPIRouter.fetchPlaces(
            latitude: latitude,
            longitude: longitude,
            radius: 1000,
            query: query
        )

        let result = await dispatcher.perform(route)

        switch result {
        case .success(let response):
            let decoder = JSONDecoder()
            do {
                let overpassResponse = try decoder.decode(OverpassResponse.self, from: response.data)

                return overpassResponse.elements.compactMap { element in
                    guard let latitude = element.lat ?? element.center?.lat,
                          let longitude = element.lon ?? element.center?.lon else {
                        return nil
                    }
                    let name = element.tags?.name ?? "Unknown Location"
                    let category = element.tags?.amenity ?? "unknown"
                    let openingState = OSMOpeningHoursParser.state(for: element.tags?.openingHours)

                    return NearbyPlacesModel(
                        id: String(element.id),
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        pointOfInterestCategory: category,
                        title: nil, // Overpass doesn't provide a formatted address easily in this query
                        openingState: openingState
                    )
                }
            } catch {
                throw NetworkError.decodingError(error)
            }
        case .failure(let error):
            throw error
        }
    }
}
