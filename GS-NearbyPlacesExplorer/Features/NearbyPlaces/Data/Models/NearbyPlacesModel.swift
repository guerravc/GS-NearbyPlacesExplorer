// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Data Transfer Object used to transport nearby place data from the remote data source
/// to the repository layer before mapping to the domain entity ``NearbyPlacesEntity``.
public struct NearbyPlacesModel: Sendable {
    /// Unique OSM element identifier.
    public let id: String
    /// Display name of the place. May be `nil` if not tagged in OSM.
    public let name: String?
    /// Latitude of the place's geographic coordinate.
    public let latitude: Double
    /// Longitude of the place's geographic coordinate.
    public let longitude: Double
    /// OSM amenity category (e.g., "cafe", "restaurant"). May be `nil`.
    public let pointOfInterestCategory: String?
    /// Formatted address or title. May be `nil` if not available from the API.
    public let title: String?
    /// Computed opening state derived from OSM `opening_hours`.
    public let openingState: PlaceOpeningState

    /// Creates a new `NearbyPlacesModel`.
    /// - Parameters:
    ///   - id: Unique OSM element identifier.
    ///   - name: Optional display name.
    ///   - latitude: Latitude coordinate.
    ///   - longitude: Longitude coordinate.
    ///   - pointOfInterestCategory: Optional OSM amenity category.
    ///   - title: Optional address or title string.
    ///   - openingState: Computed opening state. Defaults to `.notAvailable`.
    public init(
        id: String,
        name: String?,
        latitude: Double,
        longitude: Double,
        pointOfInterestCategory: String?,
        title: String?,
        openingState: PlaceOpeningState = .notAvailable
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.pointOfInterestCategory = pointOfInterestCategory
        self.title = title
        self.openingState = openingState
    }
}

extension NearbyPlacesModel {
    /// Maps this DTO to its corresponding domain entity.
    ///
    /// Applies sensible defaults for optional fields:
    /// - `name` defaults to `"Unknown"` if nil.
    /// - `pointOfInterestCategory` defaults to `""` if nil.
    ///
    /// - Returns: A ``NearbyPlacesEntity`` populated from this model.
    public func toEntity() -> NearbyPlacesEntity {
        return NearbyPlacesEntity(
            id: id,
            name: name ?? "Unknown",
            coordinate: (latitude: latitude, longitude: longitude),
            category: pointOfInterestCategory ?? "",
            address: title,
            openingState: openingState
        )
    }
}
