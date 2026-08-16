import Foundation

public struct NearbyPlacesModel: Sendable {
    public let id: String
    public let name: String?
    public let latitude: Double
    public let longitude: Double
    public let pointOfInterestCategory: String?
    public let title: String?
    
    public init(id: String, name: String?, latitude: Double, longitude: Double, pointOfInterestCategory: String?, title: String?) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.pointOfInterestCategory = pointOfInterestCategory
        self.title = title
    }
}

extension NearbyPlacesModel {
    public func toEntity() -> NearbyPlacesEntity {
        return NearbyPlacesEntity(
            id: id,
            name: name ?? "Unknown",
            coordinate: (latitude: latitude, longitude: longitude),
            category: pointOfInterestCategory ?? "",
            address: title
        )
    }
}
