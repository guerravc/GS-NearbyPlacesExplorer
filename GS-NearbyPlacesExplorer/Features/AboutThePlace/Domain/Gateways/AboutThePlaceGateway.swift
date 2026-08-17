//
//  AboutThePlaceGateway.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public protocol AboutThePlaceGateway: Sendable {
    func fetchPlaceDetails(osmId: Int) async throws -> AboutThePlaceEntity
}