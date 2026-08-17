// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Abstraction for data access of the NearbyPlaces module.
///
/// This gateway defines the contract used by the domain layer (use cases)
/// to fetch nearby points of interest from any data source (remote API, cache, etc.).
public protocol NearbyPlacesGateway: Sendable {

    /// Fetches nearby places around the given coordinates.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the center coordinate.
    ///   - longitude: Longitude of the center coordinate.
    ///   - query: Optional text filter applied to place names.
    ///     When `nil`, all nearby amenities are returned.
    /// - Returns: A result containing an array of ``NearbyPlacesEntity`` or an error.
    func fetchNearbyPlaces(
        latitude: Double,
        longitude: Double,
        query: String?
    ) async -> Result<[NearbyPlacesEntity], Error>
}
