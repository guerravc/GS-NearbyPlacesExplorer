//
//  AboutThePlaceModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation

public struct AboutThePlaceModel: Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let detail: String
    
    public init(id: UUID = UUID(), name: String = "", detail: String = "") {
        self.id = id
        self.name = name
        self.detail = detail
    }
}
