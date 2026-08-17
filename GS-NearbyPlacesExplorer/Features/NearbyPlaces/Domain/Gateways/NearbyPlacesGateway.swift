import Foundation

public protocol NearbyPlacesGateway: Sendable {
    func fetchNearbyPlaces(latitude: Double, longitude: Double, query: String?) async -> Result<[NearbyPlacesEntity], Error>
}
