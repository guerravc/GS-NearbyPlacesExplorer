// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

// MARK: - Remote (Gateway -> RemoteDataSource)

/// Remote data source for the NearbyPlaces module.
public protocol NearbyPlacesRemoteDataSource: Sendable {
    
    /// Searches for nearby places based on coordinates and an optional query.
    /// - Parameters:
    ///   - latitude: The latitude of the center coordinate.
    ///   - longitude: The longitude of the center coordinate.
    ///   - query: An optional search string.
    /// - Returns: An array of `NearbyPlacesModel`.
    /// - Throws: An error if the search fails.
    func search(latitude: Double, longitude: Double, query: String?) async throws -> [NearbyPlacesModel]
}
