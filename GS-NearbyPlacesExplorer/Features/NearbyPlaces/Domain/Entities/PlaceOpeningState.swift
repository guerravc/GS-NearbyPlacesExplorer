// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  PlaceOpeningState.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Represents the computed opening state of a place based on its OSM `opening_hours` data.
///
/// This value is derived by ``OSMOpeningHoursParser`` at the time the place data is fetched.
public enum PlaceOpeningState: Equatable, Sendable {
    /// The place is currently open according to its schedule.
    case open
    /// The place is currently closed according to its schedule.
    case closed
    /// Opening hours are not available or could not be parsed.
    case notAvailable
}
