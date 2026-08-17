// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Core domain entity representing a point of interest discovered near the user's location.
///
/// Instances are identified uniquely by their OSM element `id`.
/// Equality and hashing are based solely on `id` to support use in `Set` and as `ForEach` identifiers.
public struct NearbyPlacesEntity: Identifiable, Sendable, Equatable, Hashable {

    // MARK: - Properties

    /// Unique identifier of the place (OSM element ID).
    public let id: String
    /// Display name of the place.
    public let name: String
    /// Geographic coordinate of the place expressed as (latitude, longitude).
    public let coordinate: (latitude: Double, longitude: Double)
    /// OSM amenity category of the place (e.g., "cafe", "restaurant").
    public let category: String
    /// Optional human-readable address of the place.
    public let address: String?
    /// Current opening state derived from OSM `opening_hours` data.
    public let openingState: PlaceOpeningState

    // MARK: - Init

    /// Creates a new `NearbyPlacesEntity`.
    /// - Parameters:
    ///   - id: Unique OSM element identifier.
    ///   - name: Display name of the place.
    ///   - coordinate: Geographic coordinate as a (latitude, longitude) tuple.
    ///   - category: OSM amenity category string.
    ///   - address: Optional address string.
    ///   - openingState: Current opening state. Defaults to `.notAvailable`.
    public init(
        id: String,
        name: String,
        coordinate: (latitude: Double, longitude: Double),
        category: String,
        address: String?,
        openingState: PlaceOpeningState = .notAvailable
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.category = category
        self.address = address
        self.openingState = openingState
    }

    // MARK: - Equatable & Hashable

    /// Two entities are considered equal when they share the same OSM element `id`.
    public static func == (lhs: NearbyPlacesEntity, rhs: NearbyPlacesEntity) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the entity using only its `id`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
