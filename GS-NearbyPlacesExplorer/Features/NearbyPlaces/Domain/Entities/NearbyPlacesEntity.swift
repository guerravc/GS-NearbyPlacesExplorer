import Foundation

public struct NearbyPlacesEntity: Identifiable, Sendable, Equatable, Hashable {
    public static func == (lhs: NearbyPlacesEntity, rhs: NearbyPlacesEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public let id: String
    public let name: String
    public let coordinate: (latitude: Double, longitude: Double)
    public let category: String
    public let address: String?
    
    public init(id: String, name: String, coordinate: (latitude: Double, longitude: Double), category: String, address: String?) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.category = category
        self.address = address
    }
}
