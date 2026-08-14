// 
//  NearbyPlacesModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Domain model used by the `NearbyPlacesViewModel` and rendered
/// by the `NearbyPlacesView`.
///
/// This is a simple, feature-scoped model intended to represent the data
/// displayed by the module. You can extend it, replace its properties, or
/// map it from your own DTOs / entities as needed.
struct NearbyPlacesModel: Identifiable, Codable, Sendable {
    /// Unique identifier for the item.
    ///
    /// This value is used by SwiftUI lists and diffing algorithms.
    let id: UUID

    /// Main text shown in the list cell.
    let title: String

    /// Optional secondary text shown below the title.
    let subtitle: String?

    /// Creates a new instance of `NearbyPlacesModel`.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the item. Defaults to a new `UUID`.
    ///   - title: Main text to display.
    ///   - subtitle: Optional secondary text to display.
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}