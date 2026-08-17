// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceViewModelTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Guerra
//

import Testing
import Foundation
@testable import GS_NearbyPlacesExplorer

@MainActor
struct AboutThePlaceViewModelTests {
    
    nonisolated struct MockFetchPlaceDetailsUC: FetchPlaceDetailsUC {
        let result: Result<AboutThePlaceEntity, Error>
        func execute(_ input: Int) async -> Result<AboutThePlaceEntity, Error> {
            return result
        }
    }
    
    nonisolated struct MockCheckFavoriteStatusUC: CheckFavoriteStatusUC {
        let result: Result<Bool, Error>
        func execute(_ input: CheckFavoriteStatusInput) async -> Result<Bool, Error> {
            return result
        }
    }
    
    nonisolated struct MockToggleFavoritePlaceUC: ToggleFavoritePlaceUC {
        var result: Result<Void, Error> = .success(())
        func execute(_ input: FavoritePlaceEntity) async -> Result<Void, Error> {
            return result
        }
    }
    
    nonisolated struct MockRestoreSignInUC: RestoreSignInUC {
        let result: Result<LoginEntity, Error>
        func execute() async -> Result<LoginEntity, Error> {
            return result
        }
    }
    
    @Test func test_onAppear_success_updatesStateAndFavoriteStatus() async {
        let entity = AboutThePlaceEntity(osmId: 1, name: "Test Place", coordinate: .init(lat: 10, lon: 10), amenity: "cafe", openingHours: "24/7")
        let loginEntity = LoginEntity(id: "1", name: "User", email: "test@example.com", profileImageURL: nil)
        
        let viewModel = AboutThePlaceViewModel()
        viewModel.restoreSignInUC = MockRestoreSignInUC(result: .success(loginEntity))
        viewModel.fetchPlaceDetailsUC = MockFetchPlaceDetailsUC(result: .success(entity))
        viewModel.checkFavoriteStatusUC = MockCheckFavoriteStatusUC(result: .success(true))
        viewModel.toggleFavoritePlaceUC = MockToggleFavoritePlaceUC()
        
        await viewModel.onAppear(osmId: 1)
        
        guard let model = viewModel.placeDetails else {
            Issue.record("Expected placeDetails to be loaded")
            return
        }
        
        #expect(model.name == "Test Place")
        #expect(viewModel.isFavorite == true)
    }
    
    @Test func test_toggleFavorite_togglesStatus() async {
        let entity = AboutThePlaceEntity(osmId: 1, name: "Test Place", coordinate: .init(lat: 10, lon: 10), amenity: nil, openingHours: nil)
        let loginEntity = LoginEntity(id: "1", name: "User", email: "test@example.com", profileImageURL: nil)
        
        let viewModel = AboutThePlaceViewModel()
        viewModel.restoreSignInUC = MockRestoreSignInUC(result: .success(loginEntity))
        viewModel.fetchPlaceDetailsUC = MockFetchPlaceDetailsUC(result: .success(entity))
        viewModel.checkFavoriteStatusUC = MockCheckFavoriteStatusUC(result: .success(false))
        viewModel.toggleFavoritePlaceUC = MockToggleFavoritePlaceUC()
        
        await viewModel.onAppear(osmId: 1)
        #expect(viewModel.isFavorite == false)
        
        viewModel.toggleFavorite()
        #expect(viewModel.isFavorite == true)
    }
}
