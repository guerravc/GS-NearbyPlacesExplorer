//
//  FavoritePlace.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation
import SwiftData

@Model
public final class FavoritePlace {
    @Attribute(.unique) public var id: String
    public var userEmail: String
    public var osmId: Int
    public var name: String
    
    public init(userEmail: String, osmId: Int, name: String) {
        self.userEmail = userEmail
        self.osmId = osmId
        self.name = name
        self.id = "\(userEmail)_\(osmId)"
    }
}
