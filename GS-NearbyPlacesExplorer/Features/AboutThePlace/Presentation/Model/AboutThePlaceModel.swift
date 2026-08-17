// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

/// Lightweight presentation model used for generic list representations in the AboutThePlace feature.
///
/// - Note: Most screens use ``AboutThePlaceDetailModel`` instead. This type is kept
///   for compatibility with generic list components that only need a name and a detail string.
public struct AboutThePlaceModel: Equatable, Identifiable {
    /// Stable unique identifier for use in `List` and `ForEach`.
    public let id: UUID
    /// Display name of the item.
    public let name: String
    /// Supporting detail string (e.g., address, category).
    public let detail: String

    /// Creates a new `AboutThePlaceModel` with optional defaults.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new `UUID()`.
    ///   - name: Display name. Defaults to an empty string.
    ///   - detail: Detail text. Defaults to an empty string.
    public init(id: UUID = UUID(), name: String = "", detail: String = "") {
        self.id = id
        self.name = name
        self.detail = detail
    }
}
