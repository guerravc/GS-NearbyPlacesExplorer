//
//  AboutThePlaceDataSourcesProtocols.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public protocol AboutThePlaceLocalDataSource: Sendable {
    func getPlaceDetails(osmId: Int) async -> AboutThePlaceEntity?
    func savePlaceDetails(_ entity: AboutThePlaceEntity) async
}

public protocol AboutThePlaceRemoteDataSource: Sendable {
    func fetchElementDetails(osmId: Int) async throws -> OSMElement
}
