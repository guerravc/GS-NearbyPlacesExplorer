// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  FavoritePlace.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation
import SwiftData

/// SwiftData persistent model that stores a user's favorite place on-device.
///
/// The composite key `id` (formatted as `"email_osmId"`) ensures that each
/// user-place combination is stored only once, regardless of display name changes.
@Model
public final class FavoritePlace {
    /// Composite unique key in the format `"userEmail_osmId"`.
    @Attribute(.unique) public var id: String
    /// Email of the authenticated user who saved this favorite.
    public var userEmail: String
    /// OSM element identifier of the favorited place.
    public var osmId: Int
    /// Display name of the place at the time it was saved.
    public var name: String

    /// Creates a new `FavoritePlace` and builds the composite `id` automatically.
    /// - Parameters:
    ///   - userEmail: Email of the authenticated user.
    ///   - osmId: OSM element identifier.
    ///   - name: Display name of the place.
    public init(userEmail: String, osmId: Int, name: String) {
        self.userEmail = userEmail
        self.osmId = osmId
        self.name = name
        self.id = "\(userEmail)_\(osmId)"
    }
}
